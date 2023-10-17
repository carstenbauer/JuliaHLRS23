using MPI
using Random
using Printf

function main(N=2^28)
    MPI.Init()
    comm = MPI.COMM_WORLD
    nranks = MPI.Comm_size(comm)
    rank = MPI.Comm_rank(comm)
    # the number of ranks must
    # - greater than 1
    # - be integer power of 2
    @assert nranks > 1 && ispow2(nranks)

    Random.seed!(8)
    data = rand(N)
    # data for the master, zeros for all other ranks
    arr = (0 == rank) ? data : zeros(N)
    MPI.Barrier(comm)
    start = MPI.Wtime()

    # Broadcast: binary tree
    for k in 0:Int(log2(nranks))-1
        powk = 2^k
        for rank_src in 0:powk-1 # all sending ranks
            rank_recv = rank_src + powk # the corresponding receiving ranks
            if rank_src == rank # non-blocking send
                # println(k, ": ", rank_src, " -> ", rank_recv)
                MPI.Isend(arr, comm; dest=rank_recv)
            end
            if rank_recv == rank # blocking receive
                MPI.Recv!(arr, comm; source=rank_src)
            end
        end
    end
    MPI.Barrier(comm)
    stopp = MPI.Wtime()

    start_min = MPI.Reduce(start, MPI.MIN, comm) # the earliest start
    stopp_max = MPI.Reduce(stopp, MPI.MAX, comm) # the latest stop
    @assert isapprox(data, arr) # verification
    if 0 == rank
        walltime = stopp_max - start_min
        size_arr = sizeof(arr) * 1.0e-9
        size_msg = size_arr * 2.0 * (nranks - 1)
        @printf("Broadcast: binary tree\n")
        @printf("number of ranks        = %8d\n", nranks)
        @printf("walltime               = %8.2f sec\n", walltime)
        @printf("size of the vector     = %8.2f GB\n", size_arr)
        @printf("send and recv messages = %8.2f GB\n", size_msg)
        @printf("bandwidth              = %8.2f GB/s\n\n", size_msg / walltime)
    end

    MPI.Finalize()
end

main()
