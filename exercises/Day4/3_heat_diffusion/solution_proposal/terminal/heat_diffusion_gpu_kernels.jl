# GPU - CUDA Kernels
using CUDA
using Printf

function compute_first_order_gpu!(∂x, ∂y, T, dx, dy, nx, ny)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x # thread ID, dimension x
    iy = (blockIdx().y - 1) * blockDim().y + threadIdx().y # thread ID, dimension y

    if ix <= nx - 1
        if 2 <= iy <= ny - 1
            ∂x[ix, iy - 1] = (T[ix + 1, iy] - T[ix, iy]) / dx
        end
    end
    if 2 <= ix <= nx - 1
        if iy <= ny - 1
            ∂y[ix - 1, iy] = (T[ix, iy + 1] - T[ix, iy]) / dy
        end
    end
    return nothing
end

function update_T_gpu!(T, ∂x, ∂y, dt, α, dx, dy, nx, ny)
    #
    # Task 4 TODO: Implement the temperature update as a CUDA kernel.
    #              See `compute_first_order_gpu!` above for inspiration.
    #
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x # thread ID, dimension x
    iy = (blockIdx().y - 1) * blockDim().y + threadIdx().y # thread ID, dimension y

    if 2 <= ix <= nx - 1
        if 2 <= iy <= ny - 1
            T[ix, iy] = T[ix, iy] +
                        dt * α *
                        ((∂x[ix, iy - 1] - ∂x[ix - 1, iy - 1]) / dx +
                         (∂y[ix - 1, iy] - ∂y[ix - 1, iy - 1]) / dy)
        end
    end
    return nothing
end

@views function heat_2D_gpu_kernels(; ngrid=1024)
    # physical parameters
    lx, ly = 10.0, 10.0 # spacial dimension
    α = 1.0 # coefficient

    # spatial grid
    blockx, blocky = 32, 32
    gridx, gridy = ngrid ÷ 32, ngrid ÷ 32
    cuthreads = (blockx, blocky, 1)
    cublocks = (gridx, gridy, 1)
    nx, ny = blockx * gridx, blocky * gridy
    dx, dy = lx / nx, ly / ny
    xc = range(start = dx / 2, stop = lx - dx / 2, length = nx)
    yc = range(start = dy / 2, stop = ly - dy / 2, length = ny)

    # time discretization
    dt = min(dx^2, dy^2) / α / 4.1
    nt = 400 # timestepts

    # initial condition - gaussian sitting at the center
    T = CuArray{Float64}(exp.(.-(xc .- lx ./ 2.0) .^ 2 .- (yc .- ly ./ 2.0)' .^ 2))

    # preallocation
    ∂x = CUDA.zeros(Float64, nx - 1, ny - 2)
    ∂y = CUDA.zeros(Float64, nx - 2, ny - 1)

    # time loop
    t0 = Base.time()
    for it in 1:nt
        # time measurement (skip first 10 iterations)
        if it == 11
            t0 = Base.time()
        end

        # -------- stencil kernel --------
        # first order derivatives
        CUDA.@sync @cuda blocks=cublocks threads=cuthreads compute_first_order_gpu!(∂x, ∂y,
                                                                                    T, dx,
                                                                                    dy, nx,
                                                                                    ny)

        # update T
        #
        # Task 4 TODO: Spawn the `update_T_gpu!` kernel with `@cuda`.
        #
        CUDA.@sync @cuda blocks=cublocks threads=cuthreads update_T_gpu!(T, ∂x, ∂y, dt, α,
                                                                         dx, dy, nx, ny)
        # --------------------------------
    end
    time_s = Base.time() - t0
    T_eff = round((2 * nx * ny * sizeof(eltype(T)) / (time_s / (nt - 10))) * 1e-9, sigdigits = 2)
    @printf("T_eff = %1.2f GB/s, Time = %1.4e s \n", T_eff, time_s)
    return
end

println("GPU - Kernels:")
heat_2D_gpu_kernels()
