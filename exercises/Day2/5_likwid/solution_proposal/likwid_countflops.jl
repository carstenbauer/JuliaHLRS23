#
# First, let's check that LIKWID is working.
# The following should work and print the supported LIKWID performance groups.
#

using LIKWID
PerfMon.supported_groups()

# Great, you're set up! You can find the instructions for this exercise/tutorial here:
#     https://juliaperf.github.io/LIKWID.jl/dev/tutorials/counting_flops/

# ...Your code goes here...

daxpy!(z, a, x, y) = z .= a .* x .+ y

const N = 10_000
const a = 3.141
const x = rand(N)
const y = rand(N)
const z = zeros(N)

daxpy!(z, a, x, y);

metrics, events = @perfmon "FLOPS_DP" daxpy!(z, a, x, y);

function count_FLOPs(N)
    a = 3.141
    x = rand(N)
    y = rand(N)
    z = zeros(N)
    metrics, _ = perfmon(() -> daxpy!(z, a, x, y), "FLOPS_DP"; print=false)
    flops_per_second = first(metrics["FLOPS_DP"])["DP [MFLOP/s]"] * 1e6
    runtime = first(metrics["FLOPS_DP"])["Runtime (RDTSC) [s]"]
    return round(Int, flops_per_second * runtime)
end

NFLOPs_expected(N) = 2 * N

count_FLOPs(N)
count_FLOPs(2 * N) == NFLOPs_expected(2 * N)
