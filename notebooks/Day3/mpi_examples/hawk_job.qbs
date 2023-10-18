#!/bin/bash
#PBS -N mpi_examples
#PBS -l select=1:node_type=rome:mpiprocs=5
#PBS -l walltime=00:010:00
#PBS -j oe
#PBS -o hawk_job.output

# change to the directory that the job was submitted from
cd "$PBS_O_WORKDIR"

# load necessary modules
ml r
ml julia

# run all examples
for f in *.jl
do
    echo "Running $f"
    mpiexecjl -n 5 julia --project "$f"
done


