using Test, Distributions, Random
using DualOptimalFiltering_proof
# Run tests
@time @test 1 == 1

println("Testing common utility functions")
@time include("test_CommonUtilityFunctions.jl")

println("Testing CIR filtering")
@time include("test_CIRfiltering.jl")

println("Testing CIR smoothing")
@time include("test_CIR_smoothing.jl")

println("Testing CIR smoothing approx")
@time include("test_CIR_smoothing_approximate.jl")

println("Testing CIR joint smoothing")
@time include("test_CIR_joint_smoothing.jl")

println("Testing CIR full inference")
@time include("test_CIR_full_inference.jl")

println("Testing WF filtering")
@time include("test_WFfiltering.jl")

println("Testing WF filtering precomputed with array storage")
@time include("test_WF_precompute_ar.jl")

println("Testing pruning functions")
@time include("test_pruning_functions.jl")

println("Testing WF smoothing")
@time include("test_WF_smoothing.jl")

# println("Testing statistical distances on the simplex")
# @time include("test_statistical_distances_on_the_simplex.jl")

println("Testing Dirichlet Kernel Density Estimate")
@time include("test_dirichlet_kde.jl")


println("Testing the exact CIR likelihood functions")
@time include("test_CIR_likelihood.jl")
#

println("Testing the CIR reparametrisation functions")
@time include("test_CIR_reparam.jl")

println("Testing the WF particle filtering functions")
@time include("test_WF_particle_filter.jl")
#

println("Testing the WF likelihood functions")
@time include("test_WF_likelihood.jl")

# println("Testing the plot functions")
# @time include("test_plot_functions.jl")

# println("Testing the exact L2 distances formulas")
# @time include("test_exact_L2_distances.jl")

# println("Testing the exact L2 distances formulas")
# @time include("test_exact_L2_distances_arb.jl")
#
println("Testing the adaptive precomputing filtering functions")
@time include("test_WFfiltering_adaptive_precomputation.jl")

println("Testing the kde functions")
@time include("test_kde_for_pf_samples.jl")

println("Testing the MCMC sampler")
@time include("test_MCMC_sampler.jl")
