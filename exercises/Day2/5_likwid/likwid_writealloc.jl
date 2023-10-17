function striad!(a,b,c,d)
    for i in eachindex(a,b,c,d)
        a[i] = b[i] + c[i] * d[i]
    end
    return nothing
end

N = 1_000_000
a = rand(N)
b = rand(N)
c = rand(N)
d = rand(N)

striad!(a,b,c,d)

# 1) Looking at the Schoenhauer Triad kernel (i.e. the `striad!` function above),
# how many LOADs and STOREs to you expect to happen? Otherwise put, how many bytes do
# you think will need to be transferred to/from memory?
#
# 2) Use LIKWID.jl to empirically measure how much data has been read from / written to memory.
# Hint: @perfmon "MEM" striad!(a,b,c,d);
#
# 3) What do you find? Looking at the ratio of read and write traffic, what do you conclude
# for the number of LOADs and STOREs?
#
# Bonus: 4) Research "write-allocate" to find out more about what's going on.
#
# Bonus: 5) In the exercise "cache_sizes" we used SDAXPY rather than STRIAD.
#             * How would the bandwidth values for striad compare (qualitatively) to our
#               sdaxpy results assuming we didn't account for write-allocates?
#             * Focusing on data volume rather than data transfer,
#               how much data is hold for one iteration of sdaxpy and striad, respectively?
#               Does a factor of this data volume fit nicely into L1 cache (in either case)?
