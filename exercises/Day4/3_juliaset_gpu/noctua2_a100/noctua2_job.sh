#!/bin/bash
#SBATCH -N 1
#SBATCH -t 1
#SBATCH --cpus-per-task=16
#SBATCH --gres=gpu:a100:1
#SBATCH --partition=dgx
#SBATCH --qos=devel
#SBATCH -t 00:15:00
#SBATCH -J "juliaset_gpu"

ml r
ml lang JuliaHPC

julia --project ../juliaset_gpu.jl
