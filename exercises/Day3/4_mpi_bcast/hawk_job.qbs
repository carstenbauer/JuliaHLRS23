#!/bin/bash
#PBS -N mpi_bcast
#PBS -l select=X:node_type=rome:mpiprocs=Y
#PBS -l walltime=00:10:00
#PBS -j oe
#PBS -o hawk_job.output

# change to the directory that the job was submitted from
cd "$PBS_O_WORKDIR"

# load necessary modules
ml r
ml julia

# run program
mpiexecjl --project -n 8 julia mpi_bcast_sequential.jl
# mpiexecjl --project -n 8 julia mpi_bcast_tree.jl
# mpiexecjl --project -n 8 julia mpi_bcast_builtin.jl
