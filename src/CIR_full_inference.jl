function hidden_signal_loglikelihood_CIR(trajectory, times, δ, γ, σ)
    ll::Float64 = 0
    for k in 1:(length(trajectory)-1)
        ll += FeynmanKacParticleFilters.CIR_transition_logdensity(trajectory[k+1], trajectory[k], times[k+1]-times[k], δ, γ, σ)
    end
    return ll
end

function emitted_data_conditional_loglikelihood_CIR(data, trajectory, times, λ)
    ll::Float64 = 0
    for k in eachindex(times)
        t = times[k]
        ll += sum(logpdf.(Poisson(λ*trajectory[k]), data[t]))
    end
    return ll
end


function joint_loglikelihood_CIR(data, trajectory, times, δ, γ, σ, λ)
    return hidden_signal_loglikelihood_CIR(trajectory, times, δ, γ, σ) + emitted_data_conditional_loglikelihood_CIR(data, trajectory, times, λ)
end

function joint_sampler_CIR(data, λ, prior_logpdf, θ_init, niter; final_chain_length = 1000, silence = false)

    trajectory_chain = Array{Float64,2}(undef, niter, length(data |> keys))
    parameter_chain = Array{Float64,2}(undef, niter, 3)
    times = data |> keys |> collect |> sort

    function unnormalised_logposterior(δ, γ, σ, trajectory)::Float64
        prior_contribution = prior_logpdf(δ, γ, σ)
        if isinf(prior_contribution) #Avoids likelihood computation in this case
            return prior_contribution
        else
            return prior_contribution + joint_loglikelihood_CIR(data, trajectory, times, δ, γ, σ, λ)::Float64
        end
    end

    θ_it = θ_init

    Jtsym_rand(θ) = rand(Normal(0,0.5), 3) .+ θ

    for it in 1:niter

        print_every = max(1, floor(niter/20))

        if !silence && mod(it, print_every) == 0
            @info "$it iterations out of $niter"
        end

        # Sample trajectory

        Λ_of_t, logwms_of_t, θ_of_t, Λ_pred_of_t, logwms_pred_of_t, θ_pred_of_t = DualOptimalFiltering.filter_predict_CIR_logweights(θ_it[1], θ_it[2], θ_it[3], λ, data, silence = true)
        X_it = sample_1_trajectory_from_joint_smoothing_CIR_logweights(θ_it[1], θ_it[2], θ_it[3], Λ_of_t, logwms_of_t, θ_of_t, Λ_pred_of_t, logwms_pred_of_t, θ_pred_of_t, data)

        @debug "iteration $it"
        @debug "trajectory" X_it

        # Metropolis-Hastings step

        θ_it = draw_next_sample(θ_it, Jtsym_rand, st -> unnormalised_logposterior(st[1], st[2], st[3], X_it))

        # Record iteration

        trajectory_chain[it,:] = X_it
        parameter_chain[it,:] = θ_it

    end

    return parameter_chain, trajectory_chain
end

function joint_sampler_CIR_pruning(data, λ, prior_logpdf, θ_init, niter, do_the_pruning::Function; final_chain_length = 1000, silence = false)

    trajectory_chain = Array{Float64,2}(undef, niter, length(data |> keys))
    parameter_chain = Array{Float64,2}(undef, niter, 3)
    times = data |> keys |> collect |> sort

    function unnormalised_logposterior(δ, γ, σ, trajectory)::Float64
        prior_contribution = prior_logpdf(δ, γ, σ)
        if isinf(prior_contribution) #Avoids likelihood computation in this case
            return prior_contribution
        else
            return prior_contribution + joint_loglikelihood_CIR(data, trajectory, times, δ, γ, σ, λ)::Float64
        end
    end

    θ_it = θ_init

    Jtsym_rand(θ) = rand(Normal(0,0.5), 3) .+ θ

    for it in 1:niter

        print_every = max(1, floor(niter/20))

        if !silence && mod(it, print_every) == 0
            @info "$it iterations out of $niter"
        end

        # Sample trajectory

        #Not using the logfunction because not implemented yet
        Λ_of_t, wms_of_t, θ_of_t, Λ_pred_of_t, wms_pred_of_t, θ_pred_of_t = DualOptimalFiltering.filter_predict_CIR_pruning(θ_it[1], θ_it[2], θ_it[3], λ, data, do_the_pruning, silence = true)
        logwms_of_t = log.(wms_of_t)
        logwms_pred_of_t = log.(wms_pred_of_t)
        X_it = sample_1_trajectory_from_joint_smoothing_CIR_logweights(θ_it[1], θ_it[2], θ_it[3], Λ_of_t, logwms_of_t, θ_of_t, Λ_pred_of_t, logwms_pred_of_t, θ_pred_of_t, data)

        @debug "iteration $it"
        @debug "trajectory" X_it

        # Metropolis-Hastings step

        θ_it = draw_next_sample(θ_it, Jtsym_rand, st -> unnormalised_logposterior(st[1], st[2], st[3], X_it))

        # Record iteration

        trajectory_chain[it,:] = X_it
        parameter_chain[it,:] = θ_it

    end

    return parameter_chain, trajectory_chain
end

function joint_sampler_CIR_keep_fixed_number(data, λ, prior_logpdf, θ_init, niter, fixed_number::Int64; final_chain_length = 1000, silence = false)
    # println("filter_WF_mem2")

    function prune_keeping_fixed_number(Λ_of_t, wms_of_t)
        Λ_of_t_kept, wms_of_t_kept = keep_fixed_number_of_weights(Λ_of_t, wms_of_t, fixed_number)
        return Λ_of_t_kept, normalise(wms_of_t_kept)
    end

    joint_sampler_CIR_pruning(data, λ, prior_logpdf, θ_init, niter, prune_keeping_fixed_number; final_chain_length = 1000, silence = silence)

end
