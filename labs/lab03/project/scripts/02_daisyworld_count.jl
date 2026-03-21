using DrWatson
@quickactivate "project"
using Agents, DataFrames, Plots, CairoMakie, Statistics  # Добавлено Statistics

include(joinpath(srcdir(), "daisyworld.jl"))

black(a) = a.breed == :black
white(a) = a.breed == :white
adata = [(black, count), (white, count)]

println("Запуск модели Daisyworld...")
model = daisyworld(solar_luminosity=1.0)

println("Моделирование на 1000 шагов...")
agent_df, model_df = run!(model, 1000; adata)

println("Построение графика...")
figure = Figure(size=(800, 500))
ax = Axis(figure[1, 1], 
          xlabel="Время, шаги", 
          ylabel="Количество маргариток",
          title="Динамика популяции маргариток")

black_line = lines!(ax, agent_df.time, agent_df.count_black, 
                    color=:black, linewidth=2, label="Черные")
white_line = lines!(ax, agent_df.time, agent_df.count_white, 
                    color=:orange, linewidth=2, label="Белые")

axislegend(ax, position=:rt)

plots_path = plotsdir("daisy_population_dynamics.png")
save(plots_path, figure)
println("График сохранен: $plots_path")

println("\nРезультаты:")
println("Максимум черных: ", maximum(agent_df.count_black))
println("Максимум белых: ", maximum(agent_df.count_white))
println("Среднее черных: ", round(mean(agent_df.count_black), digits=2))
println("Среднее белых: ", round(mean(agent_df.count_white), digits=2))
