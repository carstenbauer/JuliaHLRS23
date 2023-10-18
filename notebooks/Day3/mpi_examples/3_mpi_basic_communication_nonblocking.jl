using MPI

MPI.Init()

comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
world_size = MPI.Comm_size(comm)

msg = fill(rank, 10)

if rank != 0
    # Worker: send the message `msg` to the master (rank 0)
    MPI.Isend(msg, comm; dest=0) # non-blocking
else
    # Master: receive and print the messages one-by-one
    println(msg)
    for r in 1:world_size-1
        MPI.Recv!(msg, comm; source=r) # blocking
        # we could use non-blocking MPI.Irecv! here but since we want to print the message
        # right away we would have to MPI.Wait(req). We can thus also just use MPI.Recv!.
        println(msg)
    end
end
MPI.Barrier(comm) # synchronization (master arrives here directly after MPI.Isend and waits for all other ranks)

MPI.Finalize()
