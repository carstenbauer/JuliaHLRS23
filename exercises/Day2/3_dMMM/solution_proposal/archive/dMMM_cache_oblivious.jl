function dMMM_cache_oblivious!(C, A, B)
    @assert size(C) == size(A) == size(B)
    @assert size(C, 1) == size(C, 2)
    n = size(C, 1)
    fill!(C, zero(eltype(C)))
    return add_matmul_recursive!(n, n, n, 0, 0, 0, C, A, B)
end

function add_matmul_recursive!(m, n, p, r0, k0, c0, C, A, B)
    if m + n + p <= 256 # base case: contiguous matmult
        for c in 1:p
            for k in 1:n
                @inbounds b_reg = B[k0+k, c0+c]
                for r in 1:m
                    @inbounds C[r0+r, c0+c] += A[r0+r, k0+k] * b_reg
                end
            end
        end
    else
        m2 = m ÷ 2
        n2 = n ÷ 2
        p2 = p ÷ 2
        add_matmul_recursive!(m2, n2, p2, r0, k0, c0, C, A, B)
        add_matmul_recursive!(m - m2, n2, p2, r0 + m2, k0, c0, C, A, B)
        add_matmul_recursive!(m2, n - n2, p2, r0, k0 + n2, c0, C, A, B)
        add_matmul_recursive!(m2, n2, p - p2, r0, k0, c0 + p2, C, A, B)
        add_matmul_recursive!(m - m2, n - n2, p2, r0 + m2, k0 + n2, c0, C, A, B)
        add_matmul_recursive!(m2, n - n2, p - p2, r0, k0 + n2, c0 + p2, C, A, B)
        add_matmul_recursive!(m - m2, n2, p - p2, r0 + m2, k0, c0 + p2, C, A, B)
        add_matmul_recursive!(m - m2, n - n2, p - p2, r0 + m2, k0 + n2, c0 + p2, C, A, B)
    end
    return C
end
