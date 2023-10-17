#!/bin/bash
#PBS -N saxpy_gpu
#PBS -l select=1:node_type=nv-a100-40gb:mpiprocs=8
#PBS -l walltime=00:10:00
#PBS -j oe
#PBS -o hawk_job.output

# change to the directory that the job was submitted from
cd "$PBS_O_WORKDIR"

# load necessary modules
ml r
ml julia

# run program
julia --project saxpy_gpu_solution.jl
