# Exercise: Julia Set on NVIDIA GPU

**Note: This exercise can be done on a Hawk compute node with NVIDIA A100 GPUs (recommended) or the local laptop.**

In this exercise, we will revisit the problem of computing an image of the Julia Set. This time we will compare a sequential CPU variant to a parallel GPU implementation (using a custom CUDA kernel).

Remarkable side note: We will use the same `_compute_pixel` function both for the CPU and GPU variants!

## Tasks

1) The relevant file for this exercise is `juliaset_gpu.jl`. Look for "TODO" blocks therein and complete them.

2) Run the script to benchmark the CPU and GPU variant.
  * How much faster is the GPU variant?