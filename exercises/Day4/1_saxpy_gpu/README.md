# Exercise: SAXPY on NVIDIA GPU

**Note: This exercise can be done on a Hawk compute node with NVIDIA A100 GPUs (recommended) or the local laptop.**

In this exercise, you will implement two GPU-variants of the **SAXPY** kernel (`y[i] = a * x[i] + y[i]`, `Float32` "single" precision):

1) A version using array abstractions, i.e. `CuArrays` and simple broadcasting.
2) A hand-written SAXPY CUDA kernel.

Afterwards, you'll benchmark the performance of the variants and compare it to the CUBLAS implementation by NVIDIA (that ships with CUDA). Since SAXPY is memory bound, we'll consider the achieved memory bandwidth (GB/s) as the performance metric.

You can conduct this exercise in the Terminal **or** in Jupyter, either on the local laptop or on a Hawk node with GPUs. Whatever you prefer. You can find the exercise tasks in the file `saxpy_gpu_exercise.jl` or the notebook `saxpy_gpu_exercise.ipynb`, respectively.