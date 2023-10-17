using CUDA
using BenchmarkTools
using PrettyTables

"Computes the SAXPY via broadcasting"
function saxpy_broadcast_gpu!(a, x, y)
    # --------
    #
    # Task 1: Use broadcasting to implement a SAXPY kernel. Since we will
    #         run the kernel on the GPU, don't forget to synchronize!
    #
    # --------
end

"CUDA kernel for computing SAXPY on the GPU"
function _saxpy_kernel!(a, x, y)
    i = (blockIdx().x - 1) * blockDim().x + threadIdx().x # global index
    # --------
    #
    # Task 2: Define the "scalar" SAXPY kernel here. Make sure to check that
    #         the global index `i` is within the bounds of `y` (and `x`).
    #
    # --------
    return nothing
end

"Computes SAXPY on the GPU using the custom CUDA kernel `_saxpy_kernel!`"
function saxpy_cuda_kernel!(a, x, y; nthreads, nblocks)
    # --------
    #
    # Task 3: Use the `@cuda` macro to run the kernel defined above (`_saxpy_kernel!`).
    #         Spawn the kernel with `nthreads` many threads and `nblocks` many blocks.
    #         Don't forget to synchronize :)
    #
    # --------
end

"Computes SAXPY using the CUBLAS function `CUBLAS.axpy!` provided by NVIDIA"
function saxpy_cublas!(a, x, y)
    CUDA.@sync CUBLAS.axpy!(length(x), a, x, y)
end

"Computes the GFLOP/s from the vector length `len` and the measured runtime `t`."
saxpy_flops(t; len) = 2.0 * len * 1e-9 / t # GFLOP/s

"Computes the GB/s from the vector length `len`, the vector element type `dtype`, and the measured runtime `t`."
saxpy_bandwidth(t; dtype, len) = 3.0 * sizeof(dtype) * len * 1e-9 / t # GB/s

function saxpy_gpu_bench()
    if !contains(lowercase(name(device())), "a100")
        @warn("This script was tuned for a NVIDIA A100 GPU. Your GPU: $(name(device())).")
    end
    dtype = Float32
    nthreads = 1024 # CUDA.DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK
    nblocks = 500_000
    len = nthreads * nblocks # vector length
    a = convert(dtype, 3.1415)
    xgpu = CUDA.ones(dtype, len)
    ygpu = CUDA.ones(dtype, len)

    t_broadcast_gpu = @belapsed saxpy_broadcast_gpu!($a, $xgpu, $ygpu) samples=10 evals=2
    t_cuda_kernel = @belapsed saxpy_cuda_kernel!($a, $xgpu, $ygpu; nthreads = $nthreads,
                                                 nblocks = $nblocks) samples=10 evals=2
    t_cublas = @belapsed saxpy_cublas!($a, $xgpu, $ygpu) samples=10 evals=2
    times = [t_broadcast_gpu, t_cuda_kernel, t_cublas]

    flops = saxpy_flops.(times; len)
    bandwidths = saxpy_bandwidth.(times; dtype, len)

    labels = ["Broadcast", "CUDA kernel", "CUBLAS"]
    data = hcat(labels, 1e3 .* times, flops, bandwidths)
    pretty_table(data;
                 header = (["Variant", "Runtime", "FLOPS", "Bandwidth"],
                           ["", "ms", "GFLOP/s", "GB/s"]))
    println("Theoretical Memory Bandwidth of NVIDIA A100: 1555 GB/s")
    return nothing
end

saxpy_gpu_bench()

# --------
#
# Task 4: Run the benchmark and interpret the results.
#         How does the performance of the different variants compare?
#
# --------
