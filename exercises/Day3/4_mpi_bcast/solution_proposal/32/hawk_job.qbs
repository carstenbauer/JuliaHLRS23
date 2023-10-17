#!/bin/bash
#PBS -N mpi_bcast
#PBS -l select=32:node_type=rome:mpiprocs=1
#PBS -l walltime=00:10:00
#PBS -j oe
#PBS -o hawk_job.output

# change to the directory that the job was submitted from
cd "$PBS_O_WORKDIR"

# load necessary modules
ml r
ml julia

# run program
mpiexecjl --project -n 32 --map-by ppr:1:node julia ../mpi_bcast_builtin.jl
mpiexecjl --project -n 32 --map-by ppr:1:node julia ../mpi_bcast_tree.jl
mpiexecjl --project -n 32 --map-by ppr:1:node julia ../mpi_bcast_sequential.jl
