# !! Full exercise instructions in "exercise.md" !!

# Let's include the provided snippet for
# measuring the DAXPY performance
include(joinpath(@__DIR__, "daxpy_measurement.jl"))

# Now comes you're part!
using PrettyTables

function scaling_analysis()
    # actual measurements
    membw_results = Matrix{Float64}(undef, 3, 2)
    flops_results = Matrix{Float64}(undef, 3, 2)
    for (i, pin) in enumerate((:cores, :sockets, :numa))
        for (j, init) in enumerate((:serial, :parallel))
            # println("Measuring pin=$pin with init=$init ...")
            membw, flops = measure_daxpy_perf(; pin = pin, init = init, verbose = false)
            membw_results[i, j] = round(membw; digits = 2)
            flops_results[i, j] = round(flops; digits = 2)
        end
    end

    # (pretty) printing
    println()
    pretty_table(membw_results;
                 header = [":serial", ":parallel"],
                 row_names = [":cores", ":sockets", ":numa"],
                 row_name_column_title = "# Threads = $(Threads.nthreads())",
                 title = "Memory Bandwidth (GB/s)")
    pretty_table(flops_results;
                 header = [":serial", ":parallel"],
                 row_names = [":cores", ":sockets", ":numa"],
                 row_name_column_title = "# Threads = $(Threads.nthreads())",
                 title = "Compute (GFLOP/s)")
end

scaling_analysis()
