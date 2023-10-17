using CUDA
using BenchmarkTools
using PrettyTables

"Computes the SAXPY via broadcasting"
function saxpy_broadcast_gpu!(a, x, y)
    CUDA.@sync y .= a .* x .+ y
end

"CUDA kernel for computing SAXPY on the GPU"
function _saxpy_kernel!(a, x, y)
    i = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if i <= length(y)
        @inbounds y[i] = a * x[i] + y[i]
    end
    return nothing
end

"Computes SAXPY on the GPU using the custom CUDA kernel `_saxpy_kernel!`"
function saxpy_cuda_kernel!(a, x, y; nthreads, nblocks)
    CUDA.@sync @cuda(threads=nthreads,
                     blocks=nblocks,
                     _saxpy_kernel!(a, x, y))
end

"Computes SAXPY using the CUBLAS function `CUBLAS.axpy!` provided by NVIDIA"
function saxpy_cublas!(a, x, y)
    CUDA.@sync CUBLAS.axpy!(length(x), a, x, y)
end

"Computes the GFLOP/s from the vector length `len` and the measured runtime `t`."
saxpy_flops(t; len) = 2.0 * len * 1e-9 / t # GFLOP/s

"Computes the GB/s from the vector length `len`, the vector element type `dtype`, and the measured runtime `t`."
saxpy_bandwidth(t; dtype, len) = 3.0 * sizeof(dtype) * len * 1e-9 / t # GB/s

function main()
    if !contains(lowercase(name(device())), "a100")
        @warn("This script was tuned for a NVIDIA A100 GPU. Your GPU: $(name(device())).")
    end
    dtype = Float32
    nthreads = 1024
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

main()

# Example output on Noctua 2 GPU node:
#
# ┌─────────────┬─────────┬─────────┬───────────┐
# │     Variant │ Runtime │   FLOPS │ Bandwidth │
# │             │      ms │ GFLOP/s │      GB/s │
# ├─────────────┼─────────┼─────────┼───────────┤
# │   Broadcast │ 5.03221 │ 203.489 │   1220.93 │
# │ CUDA kernel │ 4.62631 │ 221.343 │   1328.06 │
# │      CUBLAS │ 4.59823 │ 222.694 │   1336.17 │
# └─────────────┴─────────┴─────────┴───────────┘
# Theoretical Memory Bandwidth of NVIDIA A100: 1555 GB/s
