## Exercise: Heat diffusion on CPUs and GPU

#### Exercise objective
1) Understand how to (step-by-step) transform a vectorized numerical code into a faster, multithreaded loop-variant and, eventually, into a CUDA kernel running on a GPU.
2) Compare the performance of different variants of the code (vectorized CPU, vectorized GPU, multithreaded loop CPU, CUDA kernel GPU).

#### The problem
We consider the heat equation, a partial differential equation (PDE) describing the diffusion of heat over time. The PDE reads

$$ \dfrac{\partial T}{\partial t} = \alpha \left( \dfrac{\partial^2 T}{\partial x^2} + \dfrac{\partial^2 T}{\partial y^2} \right), $$

where the temperature $T = T(x,y,t)$ is a function of space ($x,y$) and time ($t$) and $\alpha$ is a scaling coefficient. Specifically, we'll consider a simple two-dimensional square geometry. As the initial condition - the starting distribution of temperature across the geometry - we choose a ["Gaussian"](https://en.wikipedia.org/wiki/Gaussian_function#:~:text=In%20mathematics%2C%20a%20Gaussian%20function,characteristic%20symmetric%20%22bell%20curve%22%20shape) positioned in the center. In summary, the starting configuration looks like this:

![](../../../../other/imgs/heat_diffusion_initial_condition.png)

#### Numerical approach
1) We discretize space (`dx`, `dy`) and time (`dt`) and evaluate everything on a grid.
2) We use the basic [finite difference method](https://en.wikipedia.org/wiki/Finite_difference_method) to compute derivatives on the grid, e.g.
$$
\dfrac{\partial T}{\partial x}(x_i) \approx \dfrac{f(x_{i+1}) - f(x_i)}{\Delta x} 
$$
3) We use a two-step process:
    a) Compute the first-order spatial derivates.
    b) Then, update the temperature field (time integration).
$$ 
\begin{align}
\partial x &= \dfrac{\Delta T}{\Delta x} \\
\partial y &= \dfrac{\Delta T}{\Delta y} \\
\Delta T &= \alpha\Delta t \left( \dfrac{\Delta (\partial x)}{\Delta x} + \dfrac{(\Delta \partial y)}{\Delta y} \right)
\end{align}
$$

#### Performance metric
Note that the derivatives give our numerical solver the character of a [stencil](https://en.wikipedia.org/wiki/Iterative_Stencil_Loops). Stencils are typically memory bound, that is, data transfer is dominating over FLOPs and consequently performance is limited by the rate at which memory is transferred between memory and the arithmetic units. For this reason we will measure the performance in terms of an [effective memory throughput metric](https://github.com/omlins/ParallelStencil.jl#performance-metric)

$$T_\textrm{eff} = \dfrac{2 n_x n_y \delta}{t_{\textrm{it}}} \cdot 10^{-9} \quad [\textrm{GB/s}]$$

where $t_{\textrm{it}}$ is the time per iteration and $\delta$ is the arithmetic precision (8 or 4 bytes for `Float64` or `Float32` respectively).

## CPU - Vectorized

In the file `heat_diffusion_animation.jl` you find a code snippet for the integration of the heat equation. 

**Task 1**

1) Implement the missing piece, that is, the update of the temperature field (marked by "TODO").
2) Create the animation by running the file (`julia heat_diffusion_animation.jl`).

**Remarks**

* Finite difference method: You can use `diff(A, dims=1) ./ dx` to compute the partial derivative of a field `A` in the x-direction (`dims=2` corresponds to y-direction).
* Don't update the temperature `T` at the boundary of the 2D square geometry. That is, only update the inner part `T[2:(end - 1), 2:(end - 1)]`.
* When implemented correctly, you should get this animation:

![](../solution_proposal/animations/heat_diffusion_animation.gif)

### Performance (without animation)

Let's get rid of the animation and measure the performance of our implementation. Please copy your solution for Task 1 above and paste it at the marked position in the file `heat_diffusion_cpu.jl`.

## CPU - Loop Multithreaded
To multithread our stencil computation - and to later transform it into a CUDA kernel - we need a version of our numerical solver in terms of loops rather than broadcasting (vectorized). In the file `heat_diffusion_cpu_loop_multithreaded.jl` you find a corresponding code snippet where we've outsourced the first-order derivation computation into a function `compute_first_order_loop_mt!` and the temperature field update into `update_T_loop_mt!`. Like previously, the first-order derivative computation is already implemented. Check it out to understand what has changed.

**Task 2**

1) Implement the missing piece, that is, the update of the temperature field via a multithreaded loop.

**Remarks**

* To respect column-major order (memory layout), the y-loop should be the outer loop and the x-loop the inner one.
* Use `@threads :static for ...` to parallelize the outer y-loop.

## GPU - Vectorized
The simplest way to make our numerical code run on the GPU is to use array abstractions, that is, `CuArray`s instead of the regular `Array`s. In the file `heat_diffusion_gpu.jl` you find precisely the same code snippet as for Task 1 (CPU vectorized).

**Task 3**

1) Initialize the arrays `T`, `∂x`, and `∂y` on the GPU by making the `CuArray`s. Leave the rest of the code the same.
2) Do you notice a change in performance?

**Remarks**

* Since the initialization of the arrays isn't part of our time measurement you can either initialize the arrays directly on the GPU or move them there before the computation. Up to you :)
* **Important:** For a fair comparison in terms of `T_eff` (effective memory bandwidth), we need to use `CuArray{Float64}` rather than just `CuArray`, which defaults to `CuArray{Float32}`.

## GPU - CUDA Kernels
Finally, we want to transform our loop implementations of `compute_first_order_loop_mt!` and `update_T_mt!` above into CUDA kernels. To that end, in the file `heat_diffusion_gpu_kernels.jl`, we simply replace the (multithreaded) `for`-loops by `if`-conditions that make sure that the indices stay within the bounds of the arrays. When the kernel is later spawned with `@cuda`, different GPU-threads will run our kernel function with different indices and thus realize the full update.

**Task 4**

1) Implement the update of the temperature field as a CUDA kernel.
2) At the marked position, spawn the `update_T_gpu!` kernel with `@cuda` using `cublocks`-many blocks and `cuthreads`-many threads.

**Remarks**

* You may take `compute_first_order_gpu!` as inspiration.

## Performance Comparison

Compare and interpret the performance of the different approaches.