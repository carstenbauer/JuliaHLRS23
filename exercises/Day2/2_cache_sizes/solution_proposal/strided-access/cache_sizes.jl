using Plots
using BenchmarkTools
using CpuId

"""
SDAXPY: `y[i] = a[i] * x[i] + y[i]` (Schoenauer triad without write-allocate.)

The arguments `y, a, x` are vectors of length `n`.
"""
function sdaxpy!(y, a, x, n)
    for i in 1:2:n
        @inbounds y[i] = a[i] * x[i] + y[i] # 8 bytes x 4 = 32 bytes data transfer
    end
end

"""
    vector_lengths(lo::Integer, hi::Integer, ni::Integer; factor::Integer=32)

Given some lower (`lo`) and upper (`hi`) bound in bytes, returns ≤ ni distinct integers
that are
- more or less evenly separated between lo and hi
- multiples of `factor`

These integers are to be used as vector lengths for the inputs to `sdaxpy!` and determine
the number of loop iterations therein.
"""
function vector_lengths(lo::Integer, hi::Integer, ni::Integer; factor::Integer=32)
    r_log = range(log10(lo / 32), log10(hi / 32), ni)
    r = round.(Integer, exp10.(r_log))
    r_factor = r .& (~(factor - 1)) # biggest multiple of factor <= number
    return unique(r_factor)
end

"""
Perform a benchmark of the SDAXPY kernel (Schoenauer triad without write-allocate).
See `vector_lengths` for explanations of the input arguments.
"""
function bench(lo, hi, n; nbench, kwargs...)
    ts = Float64[]
    Ns = vector_lengths(lo, hi, n; kwargs...)
    for n in Ns
        y = fill(1.2, n)
        a = fill(0.8, n)
        x = fill(3.14, n)
        t = @belapsed for i in 1:$nbench
            sdaxpy!($y, $a, $x, $n)
        end samples = 30
        push!(ts, t / nbench)
        println("finished n = $n, time: ", ts[end], " sec bandwidth: ", 32.0e-9 * 0.5 * n / ts[end], " GB/s")
        flush(stdout)
    end
    return Ns, ts
end

function plot_results(Ns, ts)
    p = plot(Ns, Ns .* 0.5 ./ ts .* 32.0e-9, marker=:circle, label="sdaxpy!", frame=:box, ms=2, xscale=:log10)
    ylabel!(p, "bandwidth [GB/s]")
    xlabel!(p, "vector size n")
    L1, L2, L3 = cachesize()
    mem = 4 * sizeof(Float64) # four arrays a, b, c, and d in `sdaxpy!`
    nL1 = L1 / mem
    nL2 = L2 / mem
    nL3 = L3 / mem
    vline!(p, [nL1], color=:orange, lw=2, label="L1 = $(floor(Int, nL1)) ($(L1/1024) KiB)")
    vline!(p, [nL2], color=:red, lw=2, label="L2 = $(floor(Int, nL2)) ($(L2/1024) KiB)")
    vline!(p, [nL3], color=:purple, lw=2, label="L3 = $(floor(Int, nL3)) ($(L3/1024) KiB)")
    return p
end

"""
Will perform the benchmark and save a plot of the results as png/svg files.
"""
function main()
    L1, L2, L3 = cachesize()
    Ns1, ts1 = bench(1024, L1, 12; nbench=2^24, factor=32)
    Ns2, ts2 = bench(round(Integer, L1 * 1.5), L2, 10; nbench=2^14, factor=64)
    Ns3, ts3 = bench(round(Integer, L2 * 1.5), L3, 10; nbench=2^10, factor=128)
    Ns4, ts4 = bench(round(Integer, L3 * 1.5), L3 * 32, 8; nbench=2^4, factor=64)
    p = plot_results(vcat(Ns1, Ns2, Ns3, Ns4), vcat(ts1, ts2, ts3, ts4))
    savefig(p, "cache_sizes.png")
    savefig(p, "cache_sizes.svg")
    println("Max. L1 bandwidth:\t", round(maximum(32.0e-9 .* 0.5 .* Ns1 ./ ts1); digits=2), " GB/s")
    println("Max. L2 bandwidth:\t", round(maximum(32.0e-9 .* 0.5 .* Ns2 ./ ts2); digits=2), " GB/s")
    println("Max. L3 bandwidth:\t", round(maximum(32.0e-9 .* 0.5 .* Ns3 ./ ts3); digits=2), " GB/s")
    println("Max. Memory bandwidth:\t", round(maximum(32.0e-9 .* 0.5 .* Ns4 ./ ts4); digits=2), " GB/s")
end

@time main()
