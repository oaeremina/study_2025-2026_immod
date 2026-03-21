# # Анализ с учетом неопределенности параметров
using DrWatson
@quickactivate "project"
using Agents, DataFrames, Plots, CairoMakie, Statistics, Measurements
include(srcdir("daisyworld_measurements.jl"))

# Функции для анализа
black(a) = a.breed == :black
white(a) = a.breed == :white
daisies(a) = true

land(a) = false
adata = [(black, count, daisies), (white, count, daisies), 
         (:temperature, mean, land)]
mdata = [:solar_luminosity]

# Запуск с неопределенностью
model = daisyworld(scenario=:ramp)
agent_df, model_df = run!(model, 1000; adata, mdata)

# Визуализация с доверительными интервалами
figure = Figure(size=(800, 900))

# Популяция
ax1 = Axis(figure[1, 1], ylabel="Количество маргариток")
black_line = lines!(ax1, agent_df.time, agent_df.count_black_daisies,
                    color=:black, linewidth=2)
white_line = lines!(ax1, agent_df.time, agent_df.count_white_daisies,
                    color=:red, linewidth=2)

# Температура с доверительным интервалом
ax2 = Axis(figure[2, 1], ylabel="Температура")
temp_values = Measurements.value.(agent_df.mean_temperature_land)
temp_errors = Measurements.uncertainty.(agent_df.mean_temperature_land)

band!(ax2, agent_df.time, temp_values - temp_errors, 
      temp_values + temp_errors, color=(:steelblue, 0.5))
lines!(ax2, agent_df.time, temp_values, color=:blue, linewidth=2)

# Светимость с доверительным интервалом
ax3 = Axis(figure[3, 1], xlabel="Время, шаги", ylabel="Светимость")
lum_values = Measurements.value.(model_df.solar_luminosity)
lum_errors = Measurements.uncertainty.(model_df.solar_luminosity)

band!(ax3, agent_df.time, lum_values - lum_errors,
      lum_values + lum_errors, color=(:steelblue, 0.5))
lines!(ax3, agent_df.time, lum_values, color=:blue, linewidth=2)

save(plotsdir("daisy_uncertainty_analysis.png"), figure)
println("Анализ с неопределенностью завершен")
