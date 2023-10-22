# Exercises

### `1_montecarlo_pi` (Local/Hawk, Jupyter/VSCode/Terminal)

In these exercises, you will parallelize a simple Monte Carlo algorithm that can produce the value of π=3.141... with desirable precision. Specifically, you will parallelize the same algorithm using different parallelization techniques: multithreading (e.g. `@threads`/`@spawn`), and multiprocessing (Distributed.jl and MPI.jl).

### `2_juliaset` (Local, Jupyter/VSCode)

Here, we will compute an image of the [Julia set](https://en.wikipedia.org/wiki/Julia_set) using a sequential and and two multithreaded variants (`@threads` and `@spawn`). In particular, you will learn about load balancing.

### `3_daxpy_cpu` (Hawk, VSCode/Terminal)

 You'll measure the scaling of the maximal, obtainable memory bandwidth on a Hawk node as a function of the number of Julia threads. To that end, you'll consider a multithreaded DAXPY kernel. You'll explore the basic topology of a Hawk compute node and will study how thread affinity and memory initialization can influence the performance dramatically (keyword: NUMA).

### `4_mpi_bcast` (Hawk, VSCode/Terminal)

In this exercise, we will implement our own basic variants of `MPI.Bcast!` (broadcasting) using basic MPI primitives. Specifically, you'll write a "naive" version and a more efficient binary-tree based variant.