# Exercise: SAXPY on Hawk Node

In the following exercise you will analyze the **performance scaling** of a **SAXPY** kernel (`y[i] = a * x[i] + y[i]`) for **three different thread pinning schemes** on a Hawk compute node. You will also learn about the importance of "NUMA-awareness" for performance.

1. First things first: Use [ThreadPinning.jl](https://carstenbauer.github.io/ThreadPinning.jl/stable/), in particular the functions `threadinfo()` and, e.g., `ncores()`, ``ncputhreads()`, `nnuma()`, `nsockets()`, `ncores_per_numa()` etc. to get a feeling for the architecture of the system.
    * How many cores are available?
    * Is SMT (simultaneous multithreading / "hyperthreading") enabled?
    * How many NUMA domains are there?
    * How many cores constitute a NUMA domain?
(Bonus: You can also use `topology_graphical()` from [Hwloc.jl](https://github.com/JuliaParallel/Hwloc.jl) to get a graphical visualization of the system topology.)

2. Next, make yourself familiar with `pinthreads()` from ThreadPinning.jl. For example:
    * Start a Julia session with multiple threads (e.g. `-t 10`).
    * Use `threadinfo()` to see which cores / CPU threads the Julia threads are running on. (Note: try the keyword argument `groupby=:numa`)
    * Check `?pinthreads` to understand which pinning strategies are available and play around with them (always check with `threadinfo()` afterwards)

3. Look at the given code file `saxpy_measurement.jl` and try to understand what it does.

4. To understand how thread pinning and array initialization(!) effect the observed performance, implement the function `scaling_analysis()` in the code file `exercise.jl`. Specifically, you should call `measure_saxpy_perf()` for different pinning strategies (`:cores`, `:sockets`, and `:numa`), and both initialization variants (`:serial` and `:parallel`).
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

6. What do you observe? Can you explain your findings?
    * Hint: Consider ratios of the numbers (e.g. "`:parallel / :serial`" for different pinning strategies). Can you explain the factors (approximately)?

7. Finally, run a measurement with 128 threads (one thread per core) to get an empirical estimate for the maximal memory bandwidth of a Hawk compute node.