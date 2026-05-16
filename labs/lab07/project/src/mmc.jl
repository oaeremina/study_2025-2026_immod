using Distributions
using ConcurrentSim
using ResumableFunctions
using Random
using StableRNGs

@resumable function customer(
    env::Environment,
    server::Resource,
    id::Integer,
    t_a::Float64,
    d_s::Distribution,
    rng::AbstractRNG
)
    @yield timeout(env, t_a)
    @yield request(server)
    @yield timeout(env, rand(rng, d_s))
    @yield release(server)
end

function run_mmc(; num_customers=1000, num_servers=2, mu=1.0/2.0, lam=0.9, seed=123)
    rng = StableRNG(seed)
    arrival_dist = Exponential(1/lam)
    service_dist = Exponential(1/mu)
    
    sim = Simulation()
    server = Resource(sim, num_servers)
    arrival_time = 0.0
    
    for i in 1:num_customers
        arrival_time += rand(rng, arrival_dist)
        @process customer(sim, server, i, arrival_time, service_dist, rng)
    end
    
    run(sim)
    return nothing
end

function analytical_metrics(λ, μ, c)
    ρ = λ / (c * μ)
    sum1 = sum((c * ρ)^n / factorial(n) for n in 0:c-1)
    sum2 = (c * ρ)^c / (factorial(c) * (1 - ρ))
    P0 = 1 / (sum1 + sum2)
    Pwait = (c * ρ)^c / (factorial(c) * (1 - ρ)) * P0
    Lq = ρ / (1 - ρ) * Pwait
    Wq = Lq / λ
    W = Wq + 1/μ
    L = λ * W
    return (ρ=ρ, P0=P0, Pwait=Pwait, Lq=Lq, Wq=Wq, W=W, L=L)
end
