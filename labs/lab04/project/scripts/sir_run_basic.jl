using DrWatson
@quickactivate "project"

using Agents, DataFrames, Plots, JLD2

# Путь к файлу модели
model_path = projectdir("src", "sir_model.jl")
include(model_path)

# Параметры эксперимента (без n_steps, так как его нет в initialize_sir)
params = Dict(
    :Ns => [1000, 1000, 1000],
    :β_und => [0.5, 0.5, 0.5],
    :β_det => [0.05, 0.05, 0.05],
    :infection_period => 14,
    :detection_time => 7,
    :death_rate => 0.02,
    :reinfection_probability => 0.1,
    :Is => [0, 0, 1],
    :seed => 42,
)

n_steps = 100  # количество шагов симуляции

# Создаём директории для результатов
mkpath(plotsdir())
mkpath(datadir())

# Инициализация модели
model = initialize_sir(; params...)

# Подготовка массивов для хранения данных
times = Int[]
S_vals = Int[]
I_vals = Int[]
R_vals = Int[]
total_vals = Int[]

# Запуск симуляции вручную
println("Запуск симуляции...")
for step = 1:n_steps
    Agents.step!(model, 1)
    
    push!(times, step)
    push!(S_vals, susceptible_count(model))
    push!(I_vals, infected_count(model))
    push!(R_vals, recovered_count(model))
    push!(total_vals, total_count(model))
    
    if step % 20 == 0
        println("  Шаг $step: S=$(S_vals[end]), I=$(I_vals[end]), R=$(R_vals[end])")
    end
end

# Создаём DataFrame для удобства
agent_df = DataFrame(time = times, susceptible = S_vals, infected = I_vals, recovered = R_vals)
model_df = DataFrame(time = times, total = total_vals)

# Визуализация
println("Построение графика...")
plot(agent_df.time, agent_df.susceptible, label = "Восприимчивые", xlabel = "Дни", ylabel = "Количество", linewidth=2, color=:blue)
plot!(agent_df.time, agent_df.infected, label = "Инфицированные", linewidth=2, color=:red)
plot!(agent_df.time, agent_df.recovered, label = "Выздоровевшие", linewidth=2, color=:green)
plot!(agent_df.time, model_df.total, label = "Всего (включая умерших)", linestyle = :dash, linewidth=2, color=:black)
title!("Модель SIR: Динамика эпидемии")

savefig(plotsdir("sir_basic_dynamics.png"))

# Сохранение данных
@save datadir("sir_basic_agent.jld2") agent_df
@save datadir("sir_basic_model.jld2") model_df

println("\n✅ Базовый эксперимент завершен!")
println("   График: $(plotsdir("sir_basic_dynamics.png"))")
println("   Данные: $(datadir("sir_basic_agent.jld2"))")
