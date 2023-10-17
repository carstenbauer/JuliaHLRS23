function striad!(a, b, c, d)
    for i in eachindex(a, b, c, d)
        a[i] = b[i] + c[i] * d[i]
    end
    return nothing
end

N = 1_000_000
a = rand(N)
b = rand(N)
c = rand(N)
d = rand(N)

striad!(a, b, c, d)

# 1) Looking at the Schoenhauer Triad kernel (i.e. the `striad!` function above),
# how many LOADs and STOREs to you expect to happen? Otherwise put, how many bytes do
# you think will need to be transferred to/from memory?

# Answer: Naively, one would expect 3 LOADs and 1 STORE per loop iteration.

# 2) Use LIKWID.jl to empirically measure how much data has been read from / written to memory.
# Hint: @perfmon "MEM" striad!(a,b,c,d);

using LIKWID

@perfmon "MEM" striad!(a, b, c, d);

# Example output:
# Group: MEM
# ┌───────────────────────┬───────────┐
# │                 Event │  Thread 1 │
# ├───────────────────────┼───────────┤
# │     INSTR_RETIRED_ANY │ 1.50037e7 │
# │ CPU_CLK_UNHALTED_CORE │ 1.29659e7 │
# │  CPU_CLK_UNHALTED_REF │ 8.40931e6 │
# │          CAS_COUNT_RD │   84364.0 │
# │          CAS_COUNT_WR │   21060.0 │
# │          CAS_COUNT_RD │   84288.0 │
# │          CAS_COUNT_WR │   21063.0 │
# │          CAS_COUNT_RD │   84191.0 │
# │          CAS_COUNT_WR │   20973.0 │
# │          CAS_COUNT_RD │   84296.0 │
# │          CAS_COUNT_WR │   21013.0 │
# │          CAS_COUNT_RD │   84282.0 │
# │          CAS_COUNT_WR │   21045.0 │
# │          CAS_COUNT_RD │   84378.0 │
# │          CAS_COUNT_WR │   21079.0 │
# └───────────────────────┴───────────┘
# ┌───────────────────────────────────┬────────────┐
# │                            Metric │   Thread 1 │
# ├───────────────────────────────────┼────────────┤
# │               Runtime (RDTSC) [s] │ 0.00415574 │
# │              Runtime unhalted [s] │ 0.00541527 │
# │                       Clock [MHz] │    3691.68 │
# │                               CPI │   0.864178 │
# │  Memory read bandwidth [MBytes/s] │    7789.49 │
# │  Memory read data volume [GBytes] │  0.0323711 │
# │ Memory write bandwidth [MBytes/s] │    1944.04 │
# │ Memory write data volume [GBytes] │ 0.00807891 │
# │       Memory bandwidth [MBytes/s] │    9733.53 │
# │       Memory data volume [GBytes] │    0.04045 │
# └───────────────────────────────────┴────────────┘

# 3) What do you find? Looking at the ratio of read and write traffic, what do you conclude
# for the number of LOADs and STOREs?

# Answer: We find that the ratio of read and write is ~4. We hence conclude that there are
# 4 LOADs per 1 STORE, i.e. one more LOAD than expected. This is because `a` is also read
# before written to ("write-allocate").

# Bonus: 4) Research "write-allocate" to find out more about what's going on.

# Bonus: 5) In the exercise "cache_sizes" we used SDAXPY rather than STRIAD.
#             * How would the bandwidth values for striad compare (qualitatively) to our
#               sdaxpy results assuming we didn't account for write-allocates?
#             * Focusing on data volume rather than data transfer,
#               how much data is hold for one iteration of sdaxpy and striad, respectively?
#               Does a factor of this data volume fit nicely into L1 cache (in either case)?

# Answer: The bandwidth values for STRIAD would be lower (and would thus underestimate the
#         maximal bandwidth for each memory level) because we would think that 32 bytes are
#         transferred whereas in reality it might be 40 bytes (not a power of 2).
#         As for data volume, for striad we need 4 x 8 bytes = 32 bytes whereas for
#         sdaxpy we need 3 x 8 bytes = 24 bytes (not a power of 2). Since L1 cache size
#         is usually a power of 2, we can nicely fit (parts of) the 4 vectors for striad
#         but generally not for sdaxpy.
