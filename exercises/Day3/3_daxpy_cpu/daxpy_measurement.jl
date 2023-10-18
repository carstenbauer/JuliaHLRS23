#
# You shouldn't modify this file!
#
using BenchmarkTools
using ThreadPinning
using Base.Threads

"""
Multithreaded AXPY kernel: Y[i] = a * X[i] + Y[i]
"""
function axpy_kernel!(a, X, Y)
    #
    # TODO: Implement the AXPY kernel with `@threads :static`.
    #        Use `@inbounds` to elide bound checks.
    #
    return nothing
end

"""
measure_daxpy_perf(; kwargs...) -> memory_bandwidth, flops

Estimate the memory bandwidth (GB/s) by performing a time measurement of a
DAXPY kernel. Returns the memory bandwidth (GB/s) and the compute performance (GFLOP/s).

**Keyword arguments:**
- `pin` (default: `:compact`): pinning strategy (supported by ThreadPinning)
- `init` (default: `:serial`): initialize arrays in serial or in parallel (`:parallel`)
- `N` (default: `1024*100_000``): problem size, i.e. vector length
"""
function measure_daxpy_perf(; pin=:cores, init=:serial, verbose=true, N=1024 * 100_000)
    bytes = 3 * sizeof(Float64) * N # num bytes transferred in DAXPY
    flops = 2 * N # num flops in DAXPY

    # pinning the Julia threads
    ThreadPinning.pinthreads(pin)

    a = 3.141
    if init == :parallel
        # initialize data in parallel
        X = Vector{Float64}(undef, N)
        Y = Vector{Float64}(undef, N)
        Threads.@threads :static for i in eachindex(Y)
            X[i] = rand()
            Y[i] = rand()
        end
    else
        # initialize naively (serially)
        X = rand(N)
        Y = rand(N)
    end
    t = @belapsed axpy_kernel!($a, $X, $Y) evals = 2 samples = 10
    mem_rate = bytes * 1e-9 / t # GB/s
    flop_rate = flops * 1e-9 / t # GFLOP/s
    if verbose
        println("Threads: $(Threads.nthreads()), Pinning: $pin, Init: $init")
        println("\tMemory Bandwidth (GB/s): ", round(mem_rate; digits=2))
        println("\tCompute (GFLOP/s): ", round(flop_rate; digits=2))
    end
    return mem_rate, flop_rate
end
