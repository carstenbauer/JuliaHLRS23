include(joinpath(@__DIR__, "saxpy_measurement_xpu.jl"))

using CUDA
println("GPU: ", name(CUDA.device()))
measure_membw(CUDABackend())
println()
