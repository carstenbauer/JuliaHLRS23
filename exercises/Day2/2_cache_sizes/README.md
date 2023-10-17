# Exercise: Cache Sizes

**Note: This exercise should be done on a Hawk compute node.**

In this exercise you will benchmark a **Schoenauer triad** kernel (i.e. `a[i] = b[i] + c[i] * d[i]`) and see how the observed performance is effected by the memory hierarchy, i.e. different cache levels (see image below).

<br>

**Memory hierarchy**

<img src="./imgs/memory_hierarchy.png" width=500px>

<br>

**Hint:** On most systems, you can programmatically query the cache sizes via

```julia
using CpuId
cachesize()
```

## Tasks

1) Inspect the file `cache_sizes.jl` and implement the missing pieces (look for TODO annotations).
2) Run the benchmark (see the `hawk_job.qbs` job script).
  * Do you understand the trend of the resulting plot (`cache_sizes.png`)?
  * Which maximal bandwidth values (in GB/s) do you obtain for L1, L2, L3, and main memory? (Check the output file.)

Let's investigate the performance impact of strided data access vs contiguous data access (as benchmarked above).

3) Create a copy of `cache_sizes.jl` and modify the `sdaxpy!` function such that it only performs the SDAXPY computation to every other vector element (i.e. instead of `1:n` you iterate over `1:2:n`). This corresponds to a stride size of 2.
4) Since we now only perform half as many operations and thus only half of the data transfer, we need to account for this change in all bandwidth computations. Specifically, check all lines that contain `32.0e-09` and insert an extra factor of 0.5.
5) Run the benchmark for the strided SDAXPY. How do the results compare to the contiguous case? What's the reason?
