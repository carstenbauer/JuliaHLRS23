# Exercise: LIKWID

**Note: This exercise should be done the local laptop.**

In these exercise you will use **LIKWID.jl** to
A) count the number of floating point operations performed by a CPU core, and
B) perform a "simple" memory-transfer analysis of a "**Schönauer Triad**" kernel (i.e. `a[i] = b[i] + c[i] * d[i]`).

See the files `likwid_countflops.jl` (A) and `likwid_writealloc.jl` (B) respectively.