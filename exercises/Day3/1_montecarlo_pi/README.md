# Exercises: Sampling π with Monte Carlo

In these exercises you will **parallelize a simple Monte Carlo algorithm** that can produce the value of π=3.141... with desirable precision. Specifically, you will parallelize the same algorithm using different parallelization techniques: **multithreading** (`Base.Threads` and/or FLoops.jl/ThreadsX.jl), and **multiprocessing** (`Distributed` and, separately, MPI.jl).

There are three separate (but similar) exercise instructions for multithreading (`mc_threaded`), `Distributed` (`mc_distributed`), and MPI (`mc_mpi`). The exercises are provided as Jupyter notebooks (`.ipynb`) and script files (`*.jl`). While you are free to choose which format to use, the MPI exercise must eventually be done in script form since you eventually want to call your MPI script from the command line (i.e. `mpiexecjl --project -n 6 julia mc_mpi.jl`. You are free to choose if you want to do the exercises locally or on the cluster.
