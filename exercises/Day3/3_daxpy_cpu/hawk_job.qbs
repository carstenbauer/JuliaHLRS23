#!/bin/bash
#PBS -N daxpy_cpu
#PBS -l select=1:node_type=rome:mpiprocs=1
#PBS -l walltime=00:10:00
#PBS -j oe
#PBS -o hawk_job.output

# change to the directory that the job was submitted from
cd "$PBS_O_WORKDIR"

# load necessary modules
ml r
ml julia

# run program
julia --project -t 1 scaling_benchmark.jl
julia --project -t 2 scaling_benchmark.jl
julia --project -t 4 scaling_benchmark.jl
julia --project -t 8 scaling_benchmark.jl
julia --project -t 128 scaling_benchmark.jl
