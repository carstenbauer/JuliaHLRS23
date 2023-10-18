for f in *.jl
do
    echo "Running $f"
    mpiexecjl -n 5 julia --project "$f"
done
