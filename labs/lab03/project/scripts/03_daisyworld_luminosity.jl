# # Исследование влияния солнечной активности
using DrWatson
@quickactivate "project"
using Agents, DataFrames, Plots, CairoMakie, Statistics
include(srcdir("daisyworld.jl"))

black(a) = a.breed == :black
white(a) = a.breed == :white
adata = [(black, count), (white, count)]

# Функция средней температуры
temperature(model) = mean(model.temperature)
mdata = [temperature, :solar_luminosity]

# Запуск со сценарием изменения светимости
model = daisyworld(solar_luminosity=1.0, scenario=:ramp)
agent_df, model_df = run!(model, 1000; adata, mdata)

# Создание комплексного графика
figure = Figure(size=(800, 1000))

# График популяции
ax1 = Axis(figure[1, 1], ylabel="Количество маргариток")
black_line = lines!(ax1, agent_df.time, agent_df.count_black, 
                    color=:black, linewidth=2, label="Черные")
white_line = lines!(ax1, agent_df.time, agent_df.count_white, 
                    color=:orange, linewidth=2, label="Белые")
figure[1, 2] = Legend(figure, [black_line, white_line], ["Черные", "Белые"])

# График температуры
ax2 = Axis(figure[2, 1], ylabel="Температура")
lines!(ax2, model_df.time, model_df.temperature, color=:red, linewidth=2)

# График светимости
ax3 = Axis(figure[3, 1], xlabel="Время, шаги", ylabel="Светимость")
lines!(ax3, model_df.time, model_df.solar_luminosity, color=:blue, linewidth=2)

# Скрыть подписи осей для верхних графиков
for ax in (ax1, ax2)
    ax.xticklabelsvisible = false
end

save(plotsdir("daisy_luminosity_analysis.png"), figure)
println("Анализ завершен. График сохранен.")
