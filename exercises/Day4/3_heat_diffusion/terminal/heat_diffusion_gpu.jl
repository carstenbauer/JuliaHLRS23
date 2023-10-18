# GPU - Vectorized
using CUDA
using Printf

@views function heat_2D_gpu(; ngrid=1024)
    # physical parameters
    lx, ly = 10.0, 10.0 # spacial dimension
    α = 1.0 # coefficient

    # spatial grid
    nx, ny = ngrid, ngrid
    dx, dy = lx / nx, ly / ny
    xc = range(start = dx / 2, stop = lx - dx / 2, length = nx)
    yc = range(start = dy / 2, stop = ly - dy / 2, length = ny)

    # time discretization
    dt = min(dx^2, dy^2) / α / 4.1
    nt = 400 # timestepts

    # initial condition - gaussian sitting at the center
    #
    # Task 3 TODO: Put T on the GPU by making it a `CuArray`
    #
    T = exp.(.-(xc .- lx ./ 2.0) .^ 2 .- (yc .- ly ./ 2.0)' .^ 2)

    # preallocation
    #
    # Task 3 TODO: Put ∂x and ∂y on the GPU by making it a `CuArray`
    #
    ∂x = zeros(Float64, nx - 1, ny - 2)
    ∂y = zeros(Float64, nx - 2, ny - 1)

    # time loop
    t0 = Base.time()
    for it in 1:nt
        # time measurement (skip first 10 iterations)
        if it == 11
            t0 = Base.time()
        end

        # -------- stencil kernel --------
        # first order derivatives
        ∂x .= diff(T[:, 2:(end - 1)], dims = 1) ./ dx
        ∂y .= diff(T[2:(end - 1), :], dims = 2) ./ dy
        # update T
        T[2:(end - 1), 2:(end - 1)] .= T[2:(end - 1), 2:(end - 1)] .+
                                       dt .* α .* (diff(∂x, dims = 1) ./ dx .+
                                        diff(∂y, dims = 2) ./ dy)
        # --------------------------------
    end
    time_s = Base.time() - t0
    T_eff = round((2 * nx * ny * sizeof(eltype(T)) / (time_s / (nt - 10))) * 1e-9, sigdigits = 2)
    @printf("T_eff = %1.2f GB/s, Time = %1.4e s \n", T_eff, time_s)
    return
end

println("GPU - Vectorized:")
heat_2D_gpu()
