using Distributions, Random

@testset "test kernel function" begin
    @test DualOptimalFiltering_proof.dirichletkernel_oneval([0.2,0.3,0.5], [0.16,  0.64,  0.2], 1.2) ≈ 2.3904148155639433 atol=10.0^(-5)
    @test DualOptimalFiltering_proof.dirichletkernel_oneval([0.0,0.5,0.5], [0.16,  0.64,  0.2], 1.2) == 0
    # Random.seed!(1)
    X  = rand(Dirichlet(ones(4)),10)'
    w = ones(size(X, 1))
    @test_nowarn dirichletkernel([0.2,0.3,0.4, 0.1], X, 1.2, w, size(X, 1))
    # res = [7.85877, 7.34332, 8.70397, 8.05658, 4.97756, 8.25494, 8.63194, 7.72478, 7.36807, 8.70078]
    # for i in eachindex(w)
    #     @test w[i] .≈ res[i] atol=10.0^(-5)
    # end
    X_list = [X[i,:] for i in 1:size(X,1)]
    @test_nowarn  dirichletkernel([0.2,0.3,0.4, 0.1], X, 1.2, w, size(X, 1))
    # for i in eachindex(w)
    #     @test w[i] .≈ res[i] atol=10.0^(-5)
    # end
end;


@testset "test bandwidth selection functions" begin
    Random.seed!(1)
    X  = rand(Dirichlet(ones(4)),10)'
    @test DualOptimalFiltering_proof.midrange([0,1]) ≈ 0.5
    @test_nowarn DualOptimalFiltering_proof.lcv(X, dirichletkernel, DualOptimalFiltering_proof.midrange(X), ones(size(X, 1)), size(X, 1))
    @test_nowarn DualOptimalFiltering_proof.bwlcv(X, dirichletkernel)
    @test_nowarn DualOptimalFiltering_proof.bwlcv_large_bounds(X, dirichletkernel)
    @test_nowarn DualOptimalFiltering_proof.minus_log_leaveoneout(X, dirichletkernel, DualOptimalFiltering_proof.midrange(X), ones(size(X, 1)), size(X, 1))
    @test_nowarn DualOptimalFiltering_proof.bwloo_large_bounds(X, dirichletkernel)
    X_list = [X[i,:] for i in 1:size(X,1)]
    @test_nowarn DualOptimalFiltering_proof.midrange(X_list)
    @test_nowarn  DualOptimalFiltering_proof.lcv(X_list, dirichletkernel, DualOptimalFiltering_proof.midrange(X_list), ones(size(X, 1)), size(X, 1))
    @test_nowarn DualOptimalFiltering_proof.bwlcv(X_list, dirichletkernel) 
end;
