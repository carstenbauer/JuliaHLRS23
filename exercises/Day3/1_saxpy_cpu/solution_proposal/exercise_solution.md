# Exercise: SAXPY on Hawk Node

In the following exercise you will analyze the **performance scaling** of a **SAXPY** kernel (`y[i] = a * x[i] + y[i]`) for **three different thread pinning schemes** on a Hawk compute node. You will also learn about the importance of "NUMA-awareness" for performance.

1. First things first: Use [ThreadPinning.jl](https://carstenbauer.github.io/ThreadPinning.jl/stable/), in particular the functions `threadinfo()` and, e.g., `ncores()`, ``ncputhreads()`, `nnuma()`, `nsockets()`, `ncores_per_numa()` etc. to get a feeling for the architecture of the compute node.
    * How many cores are available?
    * Is SMT (simultaneous multithreading / "hyperthreading") enabled?
    * How many NUMA domains are there?
    * How many cores constitute a NUMA domain?
(Bonus: You can also use `topology_graphical()` from [Hwloc.jl](https://github.com/JuliaParallel/Hwloc.jl) to get a graphical visualization of the compute node topology.)

2. Next, make yourself familiar with `pinthreads()` from ThreadPinning.jl. For example:
    * Start a Julia session with multiple threads (e.g. `-t 10`).
    * Use `threadinfo()` to see which cores / CPU threads the Julia threads are running on. (Note: try the keyword argument `groupby=:numa`)
    * Check `?pinthreads` to understand which pinning strategies are available and play around with them (always check with `threadinfo()` afterwards)

**"Answer":** `pinthreads(:cores)` pins threads from the first core to the last. `pinthreads(:sockets)` alternates between different sockets. `pinthreads(:numa)` alternates between NUMA domains.

3. Look at the given code file `saxpy_measurement.jl` and try to understand what it does.

**"Answer":** It performs a timing measurement of a multi-threaded, memory-bound saxpy kernel. From the known number of transferred bytes and performed FLOPs it then computes the empirical memory bandwidth in GB/s and the compute in GFLOP/s. For `init=:parallel` the used vectors are initialized in parallel (i.e. in the same way as the parallel kernel will later access them). The function `measure_membw()` also takes a keyword argument `pin` which is directly passed into `ThreadPinning.pinthreads()` and can be used for choosing a specific thread pinning strategy.

4. To understand how thread pinning and array initialization(!) effect the observed performance, implement the function `scaling_analysis()` in the code file `exercise.jl`. Specifically, you should call `measure_membw()` for different pinning strategies (`:cores`, `:sockets`, and `:numa`), and both initialization variants (`:serial` and `:parallel`).
    * You can just print the results with, e.g., `println` or, optionally, use PrettyTables.jl to produce a nice tabular layout of the results (see below for an inspiration).
    * Note: You can skip this bit and use `solution_proposal/exercise_solution.jl) if you want to directly move on to performing measurements and analyzing the findings (points 5 and 6 below).

```
Memory Bandwidth (GB/s)
┌───────────────┬─────────┬───────────┐
│ # Threads = X │ :serial │ :parallel │
├───────────────┼─────────┼───────────┤
│        :cores │   00.00 │     00.00 │
│      :sockets │   00.00 │     00.00 │
│         :numa │   00.00 │     00.00 │
└───────────────┴─────────┴───────────┘
Compute (GFLOP/s)
┌───────────────┬─────────┬───────────┐
│ # Threads = X │ :serial │ :parallel │
├───────────────┼─────────┼───────────┤
│        :cores │   00.00 │     00.00 │
│      :sockets │   00.00 │     00.00 │
│         :numa │   00.00 │     00.00 │
└───────────────┴─────────┴───────────┘
```

5. Run the modified file `exercise.jl` for various number of threads, i.e. `julia --project -t n exercise.jl` for `n = 1,2,4,8` and collect all the results.

**Examplatory results:** see  the file hawk_job.output

6. What do you observe? Can you explain your findings?
    * Hint: Consider ratios of the numbers (e.g. "`:parallel / :serial`" for different pinning strategies). Can you explain the factors (approximately)?

**"Answer":** We observe that a combination of spreading, i.e. between sockets (`:sockets`) or NUMA domains (`:numa`), and parallel initialization can give much higher memory bandwidths and flops! The former is understood from the fact that we're utilizing multiple memory channels (typically) associated with different NUMA domains much more efficiently by putting threads in different domains (whereas for `:cores` we're filling NUMA domains gradually). The fact that `:parallel` is so crucial is more subtle and related to first touch policy. See https://discourse.julialang.org/t/poor-scaling-results-with-implicitglobalgrid-jl/65170/24 for more information or ask!

**"Answer":** Let's consider `nthreads() == 8`. Essentially, we find the factors 1 (for `:cores`), 2 (for `:sockets`) and 8 (for `:numa`). This makes quite a lot of sense since with 8 threads we are precisely using this many NUMA domains / memory channels with each pinning strategy.

7. Finally, run a measurement with 128 threads (one thread per core) to get an empirical estimate for the maximal memory bandwidth of a Hawk compute node.

**Exemplatory Result:**

Memory Bandwidth (GB/s)
┌─────────────────┬─────────┬───────────┐
│ # Threads = 128 │ :serial │ :parallel │
├─────────────────┼─────────┼───────────┤
│          :cores │   36.02 │    387.48 │
│        :sockets │   36.42 │     387.6 │
│           :numa │   36.18 │    425.55 │
└─────────────────┴─────────┴───────────┘
Compute (GFLOP/s)
┌─────────────────┬─────────┬───────────┐
│ # Threads = 128 │ :serial │ :parallel │
├─────────────────┼─────────┼───────────┤
│          :cores │     3.0 │     32.29 │
│        :sockets │    3.04 │      32.3 │
│           :numa │    3.02 │     35.46 │
└─────────────────┴─────────┴───────────┘