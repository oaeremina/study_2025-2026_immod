using Distributions
using ConcurrentSim
using ResumableFunctions
using Random
using StableRNGs

mutable struct Monitor
    time::Vector{Float64}
    operational::Vector{Int}
    spare::Vector{Int}
    in_repair::Vector{Int}
    queue_length::Vector{Int}
end

Monitor() = Monitor(Float64[], Int[], Int[], Int[], Int[])

function record!(mon::Monitor, env, operational, spare, in_repair, queue_len)
    push!(mon.time, now(env))
    push!(mon.operational, operational)
    push!(mon.spare, spare)
    push!(mon.in_repair, in_repair)
    push!(mon.queue_length, queue_len)
end

mutable struct SystemState
    operational::Int
    spare::Int
    in_repair::Int
end

mutable struct RepairStats
    busy::Int
    queue::Int
end

@resumable function machine(
    env::Environment,
    repair_facility::Resource,
    state::SystemState,
    repair_stats::RepairStats,
    mon::Monitor,
    N::Int,
    S::Int,
    R::Int,
    failure_dist::Distribution,
    repair_dist::Distribution,
    rng::AbstractRNG
)
    while true
        @yield timeout(env, rand(rng, failure_dist))
        
        state.operational -= 1
        state.spare -= 1
        record!(mon, env, state.operational, state.spare, state.in_repair, repair_stats.queue)
        
        if state.spare < 0
            throw(StopSimulation("System crash at time $(now(env)): no spares"))
        end
        
        if repair_stats.busy >= R
            repair_stats.queue += 1
            record!(mon, env, state.operational, state.spare, state.in_repair, repair_stats.queue)
        end
        
        @yield request(repair_facility)
        repair_stats.busy += 1
        if repair_stats.queue > 0
            repair_stats.queue -= 1
        end
        state.in_repair += 1
        record!(mon, env, state.operational, state.spare, state.in_repair, repair_stats.queue)
        
        @yield timeout(env, rand(rng, repair_dist))
        
        @yield release(repair_facility)
        repair_stats.busy -= 1
        state.in_repair -= 1
        state.spare += 1
        record!(mon, env, state.operational, state.spare, state.in_repair, repair_stats.queue)
        
        if state.spare > 0 && state.operational < N
            state.operational += 1
            state.spare -= 1
        end
        record!(mon, env, state.operational, state.spare, state.in_repair, repair_stats.queue)
    end
end

function run_single(N::Int, S::Int, R::Int, lambda::Float64, mu::Float64, seed::Int=150)
    rng = StableRNG(seed)
    failure_dist = Exponential(lambda)
    repair_dist = Exponential(mu)
    
    sim = Simulation()
    repair_facility = Resource(sim, R)
    state = SystemState(N, S, 0)
    repair_stats = RepairStats(0, 0)
    mon = Monitor()
    
    record!(mon, sim, state.operational, state.spare, state.in_repair, 0)
    
    for i in 1:N
        @process machine(sim, repair_facility, state, repair_stats, mon, N, S, R,
                         failure_dist, repair_dist, rng)
    end
    
    msg = run(sim)
    crash_time = now(sim)
    
    return crash_time, msg, mon
end

function analytical_mttf(N::Int, S::Int, R::Int, lambda::Float64, mu::Float64)
    λ = N / lambda
    μ = R / mu
    
    if λ >= μ
        return Inf
    end
    
    ρ = λ / μ
    
    if R == 1
        return (S + 1) / λ * (1 / (1 - ρ))
    else
        return (S + 1) / λ * (1 / (1 - ρ)) * (1 - ρ^R) / (1 - ρ^(R+1))
    end
end
