using DrWatson
@quickactivate "project"

using Agents, DataFrames, Plots, CSV, Random, Statistics

# Путь к файлу модели
model_path = projectdir("src", "sir_model.jl")
include(model_path)

# Функция для создания матрицы миграции с заданной интенсивностью
function create_migration_matrix(C, intensity)
    M = ones(C, C) .* intensity ./ (C-1)
    for i = 1:C
        M[i, i] = 1 - intensity
    end
    return M
end

# Функция для измерения времени достижения пика
function peak_time(p)
    migration_rates = create_migration_matrix(p[:C], p[:migration_intensity])
    model = initialize_sir(;
        Ns = p[:Ns],
        β_und = p[:β_und],
        β_det = p[:β_det],
        infection_period = p[:infection_period],
        detection_time = p[:detection_time],
        death_rate = p[:death_rate],
        reinfection_probability = p[:reinfection_probability],
        Is = p[:Is],
        seed = p[:seed],
        migration_rates = migration_rates,
    )
    
    infected_frac(model) = count(a.status == :I for a in allagents(model)) / nagents(model)
    peak = 0.0
    peak_step = 0
    
    for step = 1:p[:n_steps]
        Agents.step!(model, 1)
        frac = infected_frac(model)
        if frac > peak
            peak = frac
            peak_step = step
        end
    end
    return (peak_time = peak_step, peak_value = peak)
end

# Сканирование интенсивности миграции
migration_intensities = 0.0:0.1:0.5
seeds = [42, 43, 44]
n_steps = 150

params_list = []
for mig in migration_intensities
    for s in seeds
        push!(params_list, Dict(
            :migration_intensity => mig,
            :C => 3,
            :Ns => [1000, 1000, 1000],
            :β_und => [0.5, 0.5, 0.5],
            :β_det => [0.05, 0.05, 0.05],
            :infection_period => 14,
            :detection_time => 7,
            :death_rate => 0.02,
            :reinfection_probability => 0.1,
            :Is => [1, 0, 0],
            :seed => s,
            :n_steps => n_steps,
        ))
    end
end

# Создаём директории
mkpath(datadir())
mkpath(plotsdir())

# Запуск
println("Запуск исследования миграции...")
println("Всего экспериментов: $(length(params_list))")
results = []

for (i, params) in enumerate(params_list)
    data = peak_time(params)
    push!(results, merge(params, Dict(pairs(data))))
    println("  [$i/$(length(params_list))] migration_intensity = $(params[:migration_intensity]), seed = $(params[:seed])")
end

# Сохраняем все прогоны
df = DataFrame(results)
CSV.write(datadir("migration_scan_all.csv"), df)
println("\n✅ Данные сохранены: $(datadir("migration_scan_all.csv"))")

# Усреднение по повторам
grouped = combine(groupby(df, [:migration_intensity]),
    :peak_time => mean => :mean_peak_time,
    :peak_value => mean => :mean_peak_value,
)

# Визуализация
println("Построение графика...")
plot(grouped.migration_intensity, grouped.mean_peak_time, 
     marker = :circle, 
     linewidth = 2,
     xlabel = "Интенсивность миграции", 
     ylabel = "Время до пика (дни)", 
     label = "Время пика",
     color = :blue)

plot!(grouped.migration_intensity, grouped.mean_peak_value .* 3000, 
      marker = :square, 
      linewidth = 2,
      xlabel = "Интенсивность миграции", 
      ylabel = "Численность в пике", 
      label = "Пиковая заболеваемость",
      color = :red)

title!("Влияние миграции на распространение эпидемии")
savefig(plotsdir("migration_effect.png"))

println("✅ График сохранён: $(plotsdir("migration_effect.png"))")
