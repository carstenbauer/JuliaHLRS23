using Plots
using Printf

const PROBLEM_SIZE = 128

@views function heat_2D_animation3D()
    # physical parameters
    lx, ly = 10.0, 10.0 # spacial dimension
    α = 1.0 # coefficient
    # plotting
    nout = 10

    # spatial grid
    nx, ny = PROBLEM_SIZE, PROBLEM_SIZE
    dx, dy = lx / nx, ly / ny
    xc = range(start = dx / 2, stop = lx - dx / 2, length = nx)
    yc = range(start = dy / 2, stop = ly - dy / 2, length = ny)
    X = [x for x in xc, _ in yc] # for plotting
    Y = [y for _ in xc, y in yc] # for plotting

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
        # update T
        T[2:(end - 1), 2:(end - 1)] .= T[2:(end - 1), 2:(end - 1)] .+
                                       dt .* α .* (diff(∂x, dims = 1) ./ dx .+
                                        diff(∂y, dims = 2) ./ dy)
        # --------------------------------

        # plotting
        if mod(it, nout) == 0
            surface(X, Y, T, xlabel = "x", ylabel = "y", title = "Heat Diffusion, i=$it",
                    clims = (0.0, 1.0), zlims = (0.0, 1.0))
            frame(anim)
        end
    end
    gif(anim, "heat_diffusion_animation3D.gif", fps = 15)
    return nothing
end

heat_2D_animation3D()
