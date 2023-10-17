# !! Full exercise instructions in "README.md" !!

# Let's include the provided snippet for
# measuring the SAXPY performance
include(joinpath(@__DIR__, "saxpy_measurement.jl"))

# Now comes you're part!
function scaling_analysis()
    # actual measurements
    #
    # TODO
    #   - loop over the pinning and initialization strategies and call
    #     `membw, flops = measure_membw(; pin=XXX, init=XXX)` for each of them.
    #   - store the results.
    #

    # (pretty) printing
    #
    # TODO
    #
end

scaling_analysis()
