#
# to be executed in the HOME directory of the user accounts on the HLRS laptops
#

# install juliaup + julia (if julia doesn't already exist)
if ! command -v julia &> /dev/null
then
    echo "julia could not be found, installing juliaup + julia ..."
    curl -fsSL https://install.julialang.org | sh -s -- --yes
fi

# install workshop environment (includes LIKWID)
git clone https://github.com/carstenbauer/JuliaHLRS23
cd JuliaHLRS23
julia install.jl full