using Logging

function draw_next_sample(state::T, Jtsym_rand::Function, unnormalised_logposterior::Function) where T
    new_state::T = Jtsym_rand(state)
    logr::Float64 = unnormalised_logposterior(new_state)::Float64 - unnormalised_logposterior(state)::Float64
    if logr > 0
        return new_state
    elseif isinf(logr)
        return state
    else
        u = rand(Uniform())
        if log(u) < logr
            return new_state
        else
            return state
        end
    end
end

function get_mcmc_samples_bare(nsamp, starting_state, Jtsym_rand_create::Function, unnormalised_logposterior::Function; silence = false)
    chain = Array{typeof(first(starting_state)), 2}(undef, length(starting_state), nsamp+1)
    chain[:,1] = starting_state

    Jtsym_rand = Jtsym_rand_create(starting_state)
    @assert size(Jtsym_rand(starting_state)) == size(starting_state)

    @inbounds for i in 2:(nsamp+1)
        if !silence && mod(i, 10) == 0
            @info "$i iterations out of $nsamp"
        end
        chain[:,i] = draw_next_sample(chain[:,i-1], Jtsym_rand, unnormalised_logposterior)
    end
    return chain
end

get_mcmc_samples(nsamp, starting_state, Jtsym_rand_create::Function, unnormalised_logposterior::Function; warmup_percentage = 0.1, final_size = Inf, silence = false) =
get_mcmc_samples_bare(nsamp, starting_state, Jtsym_rand_create, unnormalised_logposterior, silence = silence) |> c -> discard_warmup(c, warmup_percentage) |> c -> thin_chain(c, final_size)

function discard_warmup(chain, percentage)
    idcut = Int64(round(size(chain, 2) * percentage))
    if idcut == 0
        return chain
    else
        return chain[:, idcut:end]
    end
end

function estimate_step_size(total_number_of_iterations, desired_final_size)
    return floor(total_number_of_iterations/desired_final_size)
end

function thin_chain(chain, final_size)
    step = estimate_step_size(size(chain, 2), final_size)
    if step <= 1.
        return chain
    else
        return chain[:, collect(1:Int64(step):end)]
    end
end

function Jtnorm_create(starting_state)
    function Jtnorm(state)
        return rand(Normal(0,0.5), length(starting_state)) .+ state
    end
    return Jtnorm
end
