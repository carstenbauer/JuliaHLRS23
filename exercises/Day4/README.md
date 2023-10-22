# Exercises

### `1_saxpy_gpu` (Hawk/Local, Jupyter/VSCode/Terminal)

You'll try to measure the maximal, obtainable memory bandwidth of a NVIDIA A100 GPU. To that end, you'll consider different realizations of a SAXPY kernel running on the GPU. Specifically, you'll move the SAXPY computation to the GPU via array abstractions and will then hand-write a custom CUDA kernel. Afterwards, you'll compare you variants to a built-in CUBLAS implementation by NVIDIA.

### `2_juliaset_gpu` (Hawk/Local, VSCode/Terminal)

In this exercise, we will revisit the problem of computing an image of the Julia Set. But this time we will compare a sequential CPU variant to a parallel GPU implementation (using a custom CUDA kernel).

### `3_heat_diffusion` (Hawk/Local, Jupyter/VSCode/Terminal)

We'll consider the heat equation, a partial differential equation (PDE) describing the diffusion of heat over time, in two spatial dimensions. You will implement an explicit, iterative stencil solver for the equation and will learn how to move this solver from the CPU to the GPU by either using array abstractions or explicit CUDA kernels. Finally, you'll compare the performance of the different variants.

### `4_demo_saxpy_xpu` (Hawk/Local, Jupyter/VSCode/Terminal)

Not an exercise but more a demonstration of how to use [KernelAbstractions.jl](https://github.com/JuliaGPU/KernelAbstractions.jl) to write hardware agnostic code in Julia. Specifically, we provide a SAXPY implementation (c.f. exercise `1_saxpy_gpu`) that is generic and runs on CPUs as well as GPUs by NVIDIA, AMD, and Intel.