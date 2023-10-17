# # Exercise: Performance Optimization 2

# Optimize the following function.

function work!(A, B, v, N)
    val = 0
    for i in 1:N
        for j in 1:N
            val = mod(v[i],256);
            A[i,j] = B[i,j]*(sin(val)*sin(val)-cos(val)*cos(val));
        end
    end
end

# The (fixed) input is given by:

# +
N = 4000
A = zeros(N,N)
B = rand(N,N)
v = rand(Int, N);

work!(A,B,v,N)
# -

# You can benchmark as follows

using BenchmarkTools
@btime work!($A, $B, $v, $N);

# ## Optimizations

gethostname()

# ### Analytic optimization

using Test
x = rand()
@test 1-2*cos(x)*cos(x) ≈ sin(x)*sin(x)-cos(x)*cos(x)
@test -cos(2*x) ≈ sin(x)*sin(x)-cos(x)*cos(x)

# +
function work2!(A, B, v, N)
    val = 0
    for i in 1:N
        for j in 1:N
            val = mod(v[i],256);
            A[i,j] = B[i,j]*(-cos(2*val));
        end
    end
end

@btime work2!($A, $B, $v, $N);
# -

# ### Analytic + pulling out val computation

# +
function work3!(A, B, v, N)
    val = 0.0
    for i in 1:N
        val = -cos(2*mod(v[i],256))
        for j in 1:N
            A[i,j] = B[i,j]*val;
        end
    end;
end

@btime work3!($A, $B, $v, $N);
# -

# ### Analytic + separate out val computation

# +
function work4!(A, B, v, N)
    val = [-cos(2*mod(x,256)) for x in v]

    for i in 1:N
        for j in 1:N
            A[i,j] = B[i,j]*val[i];
        end
    end;
end

@btime work4!($A, $B, $v, $N);
# -

# ### Analytic + separate out val computation + switch order of loops

# +
function work5!(A, B, v, N)
    val = [-cos(2*mod(x,256)) for x in v]

    for j in 1:N
        for i in 1:N
            A[i,j] = B[i,j]*val[i];
        end
    end;
end

@btime work5!($A, $B, $v, $N);
# -

# ### Analytic + separate out val computation + switch order of loops + `@inbounds`

# +
function work6!(A, B, v, N)
    val = [-cos(2*mod(x,256)) for x in v]

    @inbounds for j in 1:N
        for i in 1:N
            A[i,j] = B[i,j]*val[i];
        end
    end;
end

@btime work6!($A, $B, $v, $N);
# -

# ### Analytic + separate out val computation + switch order of loops + `@inbounds` + lookup table

# +
lookup = [ -cos(2*j) for j in 0:255 ]

function work7!(A, B, v, N, lookup)
    val = [lookup[mod(x,256)+1] for x in v]

    @inbounds for j in 1:N
        for i in 1:N
            A[i,j] = B[i,j]*val[i];
        end
    end;
end

@btime work7!($A, $B, $v, $N, $lookup);
# -


# ## Bonus Question: Performance limit?
# 
# Look at your final optimized version of `work!`.
# 
# * What is conceptually limiting the performance, the compute capability or memory transfer?
# * Assuming that a single CPU-core in Hawk can achieve a maximal memory bandwidth of ~50 GB/s, can you give a performance bound estimate, i.e. the minimal runtime that we could possibly hope to achieve? (Hint: how many flops are performed per iteration and how many bytes are transferred?)
# * How far off is your implementation from achieving this limit (e.g. in percent)?

# +
membw = 50 # GB/s
flops = 1 # flops per iteration
traffic = 3*8 # bytes per iteration
I = flops / traffic # flops / byte

perf_bound = I*membw # GFLOPS
runtime_estimate = N^2 * 1e3 / (perf_bound * 1e9) # in ms

println("Performance bound: ", round(perf_bound, digits=2), " GFLOP/s")
println("Runtime estimate: ", round(runtime_estimate, digits=2), " ms")

t_work7 = @belapsed work7!($A, $B, $v, $N, $lookup)
ratio = runtime_estimate / (t_work7 * 1e3)
println("My best version achieves ", round(ratio * 100, digits=2), "% of the \"theoretical\" limit.")
# -