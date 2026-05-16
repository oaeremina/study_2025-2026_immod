using DrWatson
@quickactivate "project"
using Agents, DataFrames, Plots, CairoMakie, Statistics, CSV
include(joinpath(srcdir(), "daisyworld.jl"))

# Функции для подсчета
black(a) = a.breed == :black
white(a) = a.breed == :white
adata = [(black, count), (white, count)]

# Сетка параметров для исследования
param_grid = Dict(
    :max_age => [20, 30, 40],
    :init_white => [0.1, 0.3, 0.5],
    :solar_luminosity => [0.8, 1.0, 1.2]
)

# Генерируем все комбинации параметров
all_params = dict_list(param_grid)
println("="^60)
println("ПАРАМЕТРИЧЕСКОЕ ИССЛЕДОВАНИЕ МОДЕЛИ DAISYWORLD")
println("="^60)
println("Всего комбинаций параметров: ", length(all_params))

# Массив для хранения результатов
results = []

# Запуск для каждой комбинации параметров
for (i, params) in enumerate(all_params)
    println("\n[$i/$(length(all_params))] Запуск с параметрами:")
    for (key, value) in params
        println("  $key = $value")
    end
    
    # Создание модели с текущими параметрами
    model = daisyworld(; params...)
    
    # Запуск модели
    agent_df, _ = run!(model, 500; adata)
    
    # Сбор статистики
    push!(results, merge(params, Dict(
        :max_black => maximum(agent_df.count_black),
        :max_white => maximum(agent_df.count_white),
        :mean_black => round(mean(agent_df.count_black), digits=2),
        :mean_white => round(mean(agent_df.count_white), digits=2),
        :std_black => round(std(agent_df.count_black), digits=2),
        :std_white => round(std(agent_df.count_white), digits=2)
    )))
    
    println("  ✓ Завершено")
end

# Создание сводной таблицы
println("\n" * "="^60)
println("РЕЗУЛЬТАТЫ ПАРАМЕТРИЧЕСКОГО АНАЛИЗА")
println("="^60)

results_df = DataFrame(results)
println(results_df)

# Сохранение результатов в CSV
csv_path = datadir("parametric_results.csv")
CSV.write(csv_path, results_df)
println("\n✓ Результаты сохранены в: $csv_path")

# Визуализация результатов
println("\nСоздание графиков...")

# График 1: Влияние max_age на популяцию
figure1 = Figure(size=(800, 600))
ax1 = Axis(figure1[1, 1], 
           xlabel="Максимальный возраст", 
           ylabel="Средняя численность",
           title="Влияние максимального возраста на популяцию")

for lum in [0.8, 1.0, 1.2]
    subset_df = filter(row -> row.solar_luminosity == lum, results_df)
    if !isempty(subset_df)
        lines!(ax1, subset_df.max_age, subset_df.mean_black, 
               marker=:circle, label="Черные (L=$lum)")
        lines!(ax1, subset_df.max_age, subset_df.mean_white, 
               marker=:square, label="Белые (L=$lum)", linestyle=:dash)
    end
end
axislegend(ax1, position=:lt)
save(plotsdir("parametric_age_analysis.png"), figure1)
println("✓ График 1 сохранен")

# График 2: Влияние начальной доли белых
figure2 = Figure(size=(800, 600))
ax2 = Axis(figure2[1, 1], 
           xlabel="Начальная доля белых", 
           ylabel="Средняя численность",
           title="Влияние начального распределения")

for lum in [0.8, 1.0, 1.2]
    subset_df = filter(row -> row.solar_luminosity == lum, results_df)
    if !isempty(subset_df)
        lines!(ax2, subset_df.init_white, subset_df.mean_black, 
               marker=:circle, label="Черные (L=$lum)")
        lines!(ax2, subset_df.init_white, subset_df.mean_white, 
               marker=:square, label="Белые (L=$lum)", linestyle=:dash)
    end
end
axislegend(ax2, position=:lt)
save(plotsdir("parametric_initial_analysis.png"), figure2)
println("✓ График 2 сохранен")

# График 3: Влияние светимости
figure3 = Figure(size=(800, 600))
ax3 = Axis(figure3[1, 1], 
           xlabel="Светимость", 
           ylabel="Средняя численность",
           title="Влияние солнечной светимости")

for age in [20, 30, 40]
    subset_df = filter(row -> row.max_age == age, results_df)
    if !isempty(subset_df)
        lines!(ax3, subset_df.solar_luminosity, subset_df.mean_black, 
               marker=:circle, label="Черные (age=$age)")
        lines!(ax3, subset_df.solar_luminosity, subset_df.mean_white, 
               marker=:square, label="Белые (age=$age)", linestyle=:dash)
    end
end
axislegend(ax3, position=:lt)
save(plotsdir("parametric_luminosity_analysis.png"), figure3)
println("✓ График 3 сохранен")

println("\n" * "="^60)
println("ПАРАМЕТРИЧЕСКИЙ АНАЛИЗ ЗАВЕРШЕН")
println("="^60)
println("\nРезультаты сохранены в:")
println("  - data/parametric_results.csv")
println("  - plots/parametric_age_analysis.png")
println("  - plots/parametric_initial_analysis.png")
println("  - plots/parametric_luminosity_analysis.png")
