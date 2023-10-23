using Pkg
println("\n\n\tActivating environment in $(pwd())...")
pkg"activate ."
println("\n\n\tInstantiating environment... (i.e. downloading + installing + precompiling packages)");
flush(stdout);
pkg"instantiate"
pkg"precompile"

println("\n\n\tLoading PythonCall... (to trigger Conda related downloads / installations)");
flush(stdout);
using PythonCall

println("\n\n\tLoading CUDA (to trigger lazy artifact downloads) ...");
flush(stdout);
using CUDA
CUDA.precompile_runtime()
if CUDA.functional()
    CUDA.versioninfo()
end

println("\n\n\tInstalling mpiexecjl ...");
flush(stdout);
using MPI
MPI.install_mpiexecjl(; force=true)
println("\n\n\t!!!!!!!!!!\n\tYou need to manually put mpiexecjl on PATH. Put the following into your .bashrc (or similar):");
flush(stdout);
println("\t\texport PATH=$(joinpath(DEPOT_PATH[1], "bin")):\$PATH");
flush(stdout);
println("\t!!!!!!!!!!")

if length(ARGS) == 1 && ARGS[1] == "full" && Sys.islinux()
    println("\n\n\t -- FULL MODE: Modifying `.bashrc` ...!")
    bashrc = joinpath(ENV["HOME"], ".bashrc")
    if isfile(bashrc)
        entry = "\nexport PATH=$(joinpath(first(DEPOT_PATH), "bin")):\$PATH\n"
        open(bashrc, "a") do f
            write(f, entry)
        end
    else
        println("\t\t `.bashrc` not found. Skipping!")
    end

    println("\n\n\t -- FULL MODE: Installing LIKWID ...!")
    likwid_dir = joinpath(@__DIR__, "orga", "likwid_local_install")
    cd(likwid_dir) do
        run(`sh install_likwid.sh`)
    end
end

println("\n\n\tDone!")
