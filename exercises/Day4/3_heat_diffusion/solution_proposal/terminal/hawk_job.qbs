#!/bin/bash
#PBS -N heat_diffusion
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
#julia --project heat_diffusion_animation.jl
julia --project heat_diffusion_cpu.jl
julia --project -t 128 heat_diffusion_cpu_loop_multithreaded.jl
julia --project heat_diffusion_gpu.jl
julia --project heat_diffusion_gpu_kernels.jl
