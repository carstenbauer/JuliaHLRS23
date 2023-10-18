# Demonstration: SAXPY on XPU

(XPU stands for CPU and GPU)

This isn't really an exercise but more a demonstration of how to use [KernelAbstractions.jl](https://github.com/JuliaGPU/KernelAbstractions.jl) to write hardware agnostic code. Specifically, the SAXPY implementation in this folder (`saxpy_measurement_xpu.jl` or `saxpy_xpu.ipynb`) is generic and runs on CPUs as well as GPUs by NVIDIA, AMD, and Intel. 

Feel free to study the very short code!