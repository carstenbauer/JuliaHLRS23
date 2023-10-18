using CUDA
# using Plots
using BenchmarkTools

@assert CUDA.functional()
const MAX_THREADS_PER_BLOCK = CUDA.attribute(device(), CUDA.DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK)

"""
Computes a pixel (`i`, `j`) in the Julia set image
(of size `n`x`n`). It return the number of iterations.
"""
function _compute_pixel(i, j, n; max_iter=255, c=-0.79f0 + 0.15f0 * im)
    x = Float32(-2.0 + (j - 1) * 4.0 / (n - 1))
    y = Float32(-2.0 + (i - 1) * 4.0 / (n - 1))

    z = x + y * im
    iter = max_iter
    for k in 1:max_iter
        if abs2(z) > 4.0
            iter = k - 1
            break
        end
        z = z^2 + c
    end
    return iter
end

# CPU -----
function compute_juliaset_cpu(N)
    img = zeros(Int32, N, N)
    for j in 1:N
        for i in 1:N
            # TODO
            iter = _compute_pixel(i, j, N)
            @inbounds img[i, j] = iter
        end
    end
    return img
end

# GPU -----
function _compute_pixel_gpu!(img)
    # TODO
    i = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    j = (blockIdx().y - 1) * blockDim().y + threadIdx().y
    n = size(img, 1)
    if (i ≤ n && j ≤ n)
        iter = _compute_pixel(i, j, n)
        @inbounds img[i, j] = iter
    end
    return nothing
end

function compute_juliaset_gpu(N)
    # TODO
    img_gpu = CUDA.zeros(Int32, N, N)
    threads = (isqrt(MAX_THREADS_PER_BLOCK), isqrt(MAX_THREADS_PER_BLOCK))
    blocks = cld.((N, N), threads)
    CUDA.@sync begin
        @cuda threads = threads blocks = blocks _compute_pixel_gpu!(img_gpu)
    end
    img_cpu = Array(img_gpu)
    return img_cpu
end




function main()
    N = 2048
    img1 = compute_juliaset_gpu(N)
    # heatmap(img1)
    img2 = compute_juliaset_cpu(N)
    # heatmap(img2)
    println("CPU and GPU results match: ", img1 ≈ img2)
    t_cpu = @belapsed compute_juliaset_cpu($N) samples = 10 evals = 3 # ~ 158 ms
    t_gpu = @belapsed compute_juliaset_gpu($N) samples = 10 evals = 3 # ~ 2 ms (includes gpu -> host transfer)
    t_transfer = @belapsed Array(img_gpu) setup = (img_gpu = CUDA.zeros(Int32, $N, $N)) samples = 10 evals = 3 # ~ 1.6 ms
    println("CPU (sequential):\t", round(t_cpu * 1e3; digits=2), "ms")
    println("GPU (incl. transfer):\t", round(t_gpu * 1e3; digits=2), "ms")
    println("GPU (w/o transfer):\t", round((t_gpu - t_transfer) * 1e6; digits=2), "μs")
end

main()
