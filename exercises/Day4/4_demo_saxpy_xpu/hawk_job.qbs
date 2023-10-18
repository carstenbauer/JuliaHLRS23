#!/bin/bash
#PBS -N saxpy_xpu
#PBS -l select=1:node_type=nv-a100-40gb
#PBS -l walltime=00:15:00
#PBS -j oe
#PBS -o hawk_job.output

# change to the directory that the job was submitted from
cd "$PBS_O_WORKDIR"

# load necessary modules
ml r
ml julia

# run program
julia --project -t 1 run_cpu.jl
julia --project -t 2 run_cpu.jl
julia --project -t 4 run_cpu.jl
julia --project -t 8 run_cpu.jl
julia --project -t 128 run_cpu.jl
julia --project -t 1 run_gpu.jl
