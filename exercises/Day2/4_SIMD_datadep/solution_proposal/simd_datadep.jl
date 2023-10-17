using BenchmarkTools
using LoopVectorization
using InteractiveUtils
using Random

const LOOP_ITERATIONS = 8192
const N = LOOP_ITERATIONS + 2

"naive loop (reference results)"
function loop_naive!(a, b, c, d)
    @inbounds for i in 1:LOOP_ITERATIONS
        a[i] = a[i] + b[i]
        b[i+2] = c[i] + d[i]
    end
end

"`@simd` loop (naive version)"
function loop_naive_simd!(a, b, c, d)
    @inbounds @simd for i in 1:LOOP_ITERATIONS
        a[i] = a[i] + b[i]
        b[i+2] = c[i] + d[i]
    end
end

"naive loop (optimized version)"
function loop_opt!(a, b, c, d)
    @inbounds for i in 1:LOOP_ITERATIONS
        b[i+2] = c[i] + d[i]
    end
    @inbounds for i in 1:LOOP_ITERATIONS
        a[i] = a[i] + b[i]
    end
end

"`@simd` loop (optimized version)."
function loop_opt_simd!(a, b, c, d)
    @inbounds @simd for i in 1:LOOP_ITERATIONS
        b[i+2] = c[i] + d[i]
    end
    @inbounds @simd for i in 1:LOOP_ITERATIONS
        a[i] = a[i] + b[i]
    end
end

"Verify the correctness of all implementations."
function check_correctness()
    Random.seed!(3)
    # the original vectors
    a_orig = rand(Float32, N)
    b_orig = rand(Float32, N)
    c_orig = rand(Float32, N)
    d_orig = rand(Float32, N)
    # the reference vectors for verification
    a_ref = zeros(Float32, N)
    b_ref = zeros(Float32, N)
    c_ref = zeros(Float32, N)
    d_ref = zeros(Float32, N)
    # the vectors for computation
    a = zeros(Float32, N)
    b = zeros(Float32, N)
    c = zeros(Float32, N)
    d = zeros(Float32, N)

    function reset_abcd!(a, a_orig, b, b_orig, c, c_orig, d, d_orig)
        copy!(a, a_orig)
        copy!(b, b_orig)
        copy!(c, c_orig)
        copy!(d, d_orig)
    end

    reset_abcd!(a_ref, a_orig, b_ref, b_orig, c_ref, c_orig, d_ref, d_orig)
    loop_naive!(a_ref, b_ref, c_ref, d_ref)

    reset_abcd!(a, a_orig, b, b_orig, c, c_orig, d, d_orig)
    loop_naive_simd!(a, b, c, d)
    println("correctness for the naive loop + `@simd`: ", isapprox(a, a_ref))

    reset_abcd!(a, a_orig, b, b_orig, c, c_orig, d, d_orig)
    loop_opt!(a, b, c, d)
    println("correctness for the optimized loop: ", isapprox(a, a_ref))

    reset_abcd!(a, a_orig, b, b_orig, c, c_orig, d, d_orig)
    loop_opt_simd!(a, b, c, d)
    println("correctness for the optimized loop + `@simd`: ", isapprox(a, a_ref))
    println()
    return nothing
end

"Helper function for analysis"
function show_code_native(f::F) where {F}
    Random.seed!(3)
    # the vectors for computation
    a = rand(Float32, N)
    b = rand(Float32, N)
    c = rand(Float32, N)
    d = rand(Float32, N)

    @code_native debuginfo = :none syntax = :intel f(a, b, c, d)
    println("\n\n\n")
    return nothing
end


function main()
    Random.seed!(3)
    check_correctness()

    # the vectors for computation
    a = rand(Float32, N)
    b = rand(Float32, N)
    c = rand(Float32, N)
    d = rand(Float32, N)

    walltime = @belapsed loop_naive!($a, $b, $c, $d) samples = 5 evals = 3
    println("the naive loop: ", round(walltime * 1e6; digits=2), " μs")
    walltime = @belapsed loop_naive_simd!($a, $b, $c, $d) samples = 5 evals = 3
    println("the naive loop + @simd: ", round(walltime * 1e6; digits=2), " μs")
    walltime = @belapsed loop_opt!($a, $b, $c, $d) samples = 5 evals = 3
    println("the optimized loop: ", round(walltime * 1e6; digits=2), " μs")
    walltime = @belapsed loop_opt_simd!($a, $b, $c, $d) samples = 5 evals = 3
    println("the optimized loop + @simd: ", round(walltime * 1e6; digits=2), " μs")

    println("--------- loop_naive! ---------")
    show_code_native(loop_naive!)
    println("--------- loop_naive_simd! ---------")
    show_code_native(loop_naive_simd!)
    println("--------- loop_opt! ---------")
    show_code_native(loop_opt!)
    println("--------- loop_opt_simd! ---------")
    show_code_native(loop_opt_simd!)
    return nothing
end

main()
