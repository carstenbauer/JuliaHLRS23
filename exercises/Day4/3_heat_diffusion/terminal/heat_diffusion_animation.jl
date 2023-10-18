using Plots
using Printf

@views function heat_2D_animation(; ngrid=128)
    # physical parameters
    lx, ly = 10.0, 10.0 # spacial dimension
    α = 1.0 # coefficient
    # plotting
    nout = 10

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
    anim = Animation(mktempdir(), String[])
    for it in 1:nt
        # -------- stencil kernel --------
        # first order derivatives
        ∂x .= diff(T[:, 2:(end - 1)], dims = 1) ./ dx
        ∂y .= diff(T[2:(end - 1), :], dims = 2) ./ dy

        #
        # Task 1 TODO: update T
        #

        # --------------------------------

        # plotting
        if mod(it, nout) == 0
            heatmap(xc, yc, T', xlabel = "x", ylabel = "y", title = "Heat Diffusion, i=$it",
                    clims = (0.0, 1.0))
            frame(anim)
        end
    end
    gif(anim, "heat_diffusion_animation.gif", fps = 15)
    return nothing
end

heat_2D_animation()
