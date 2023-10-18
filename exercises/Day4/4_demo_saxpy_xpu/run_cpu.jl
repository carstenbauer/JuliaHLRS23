include(joinpath(@__DIR__, "saxpy_measurement_xpu.jl"))

println("Threads: ", Threads.nthreads())
measure_membw(CPU(; static = true))
println()
