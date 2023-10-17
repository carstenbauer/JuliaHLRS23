# Exercise: Custom Broadcasting with MPI

**This exercise is supposed to be done on the Hawk cluster!**

In this exercise we will implement our own basic variants of `MPI.Bcast!` (broadcasting) using basic MPI primitives.

## What is broadcasting?

Sending data (e.g. an array) from one MPI rank (typically rank 0, referred to as "master" below) to all other MPI ranks.

## A) Sequential broadcast

First, we want to implement the most naive version of broadcasting you can think of:  a **sequential** variant in which the master (rank 0) sends the data to all other MPI ranks which in turn receive it.

Specifically, we want to use the non-blocking send primitive
* `MPI.Isend(data, communicator; dest=receiving_rank)`

and the blocking receive primitive

* `MPI.Recv!(data, communicator; source=sending_rank)`

**Task 1:** Look at the file `mpi_bcast_sequential.jl` and implement the sequential broadcasting variant. (Look for the TODO annotation.)

If you need/want an interactive session on a compue node, see `get-cpu-node-interactive-MPI.sh` in your home directory on Hawk. You should run your code via `mpiexecjl --project -n 8 julia mpi_bcast_sequential.jl` (where 8 is the number of MPI ranks). A job script skeleton is provided in `hawk_job.qbs`. Note that in the line `#PBS -l select=X:node_type=rome:mpiprocs=Y` the `X` and `Y` are placeholders for how many compute nodes (`X`) and how many MPI ranks per node (`Y`) you want.

## B) Binary-tree broadcast

To improve upon the sequential variant above, we want to implement a **binary-tree version of broadcast**. The idea is depicted in the image below (if you can't see the image, take a look at `imgs/mpi_bcast_tree.png`).

<img src="./imgs/mpi_bcast_tree.png" width=600px>

(Circles with numbers are MPI ranks. Black arrows indicate communication between ranks. Grey lines are visual supplements to indicate the full tree structure.)

Instead of having the master send data to each MPI rank individually, one after another, we utilize the fact that after a send/receive the data is present on another MPI rank which can itself pass the data on to another rank. Example from the image: once MPI rank 1 has received the data from rank 0 it will pass it on to rank 3 (and afterwards also to rank 5). The master (rank 0) thus never has to communicate with rank 3 (or 5) directly.

**Task 1:** Assume for simplicity that all communications take precisely the same time `t` and, when triggered at the same time, can happen perfectly in parallel. How long would a broadcast operation with this approach take if there are `N` MPI ranks in total? How long would the sequential variant take?

(You can assume that `N` is a power of 2.)

**Task 2:** Look at the file `mpi_bcast_tree.jl` and implement the tree broadcasting variant. (Look for the TODO annotation.)

Hint: You'll need `log2(nranks)` and `2^x`.

**Task 3:** In `mpi_bcast_builtin.jl` we provide a script that simply calls the built-in, optimized variant `MPI.Bcast!`. Create a job file in which you run all three variants (sequential, binary tree, built-in). How do they compare to each other for various number of compute nodes? (e.g. try maybe 8, 16, and 32 nodes with one or two MPI ranks per node.).

Note: To go to large number of nodes you might need to drop the course reservation annotation.