# CPU - Loop Multithreaded
using ThreadPinning
using Printf

if Threads.nthreads() == 1
    error("This part is supposed to be run with multiple Julia threads.")
end
pinthreads(:numa)

function compute_first_order_loop_mt!(∂x, ∂y, T, dx, dy, nx, ny)
    Threads.@threads :static for iy in 2:(ny - 1)
        for ix in 1:(nx - 1)
            ∂x[ix, iy - 1] = (T[ix + 1, iy] - T[ix, iy]) / dx
        end
    end
    Threads.@threads :static for iy in 1:(ny - 1)
        for ix in 2:(nx - 1)
            ∂y[ix - 1, iy] = (T[ix, iy + 1] - T[ix, iy]) / dy
        end
    end
    return nothing
end

function update_T_loop_mt!(T, ∂x, ∂y, dt, α, dx, dy, nx, ny)
    #
    # Task 2 TODO: Implement update of T via multithreaded loops.
    #              See `compute_first_order_loop_mt!` for inspiration.
    #
    Threads.@threads :static for iy in 2:(ny - 1)
        for ix in 2:(nx - 1)
            T[ix, iy] = T[ix, iy] +
                        dt * α *
                        ((∂x[ix, iy - 1] - ∂y[ix - 1, iy - 1]) / dx +
                         (∂y[ix - 1, iy] - ∂y[ix - 1, iy - 1]) / dy)
        end
    end
    return nothing
end

@views function heat_2D_loop_multithreaded(; ngrid=1024)
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
    T = exp.(.-(xc .- lx ./ 2.0) .^ 2 .- (yc .- ly ./ 2.0)' .^ 2)

    # preallocation
    ∂x = zeros(nx - 1, ny - 2)
    ∂y = zeros(nx - 2, ny - 1)

    # time loop
    t0 = Base.time()
    for it in 1:nt
        # time measurement (skip first 10 iterations)
        if it == 11
            t0 = Base.time()
        end

        # -------- stencil kernel --------
        # first order derivatives
        compute_first_order_loop_mt!(∂x, ∂y, T, dx, dy, nx, ny)
        # update T
        update_T_loop_mt!(T, ∂x, ∂y, dt, α, dx, dy, nx, ny)
        # --------------------------------
    end
    time_s = Base.time() - t0
    T_eff = round((2 * nx * ny * sizeof(eltype(T)) / (time_s / (nt - 10))) * 1e-9, sigdigits = 2)
    @printf("T_eff = %1.2f GB/s, Time = %1.4e s \n", T_eff, time_s)
    return nothing
end

println("CPU - Loop - Multithreaded ($(Threads.nthreads()) threads):")
heat_2D_loop_multithreaded()
