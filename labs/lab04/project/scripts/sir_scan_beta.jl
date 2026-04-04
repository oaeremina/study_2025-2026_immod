using DrWatson
@quickactivate "project"

using Agents, DataFrames, Plots, CSV, Random, Statistics

# Путь к файлу модели
model_path = projectdir("src", "sir_model.jl")
include(model_path)

# Функция для запуска одного эксперимента и возврата метрик
function run_experiment(p)
    # Создаём β_und и β_det на основе скалярного beta
    beta = p[:beta]
    β_und = fill(beta, 3)
    β_det = fill(beta/10, 3)
    
    model = initialize_sir(;
        Ns = p[:Ns],
        β_und = β_und,
        β_det = β_det,
        infection_period = p[:infection_period],
        detection_time = p[:detection_time],
        death_rate = p[:death_rate],
        reinfection_probability = p[:reinfection_probability],
        Is = p[:Is],
        seed = p[:seed],
    )
    
    infected_fraction(model) = count(a.status == :I for a in allagents(model)) / nagents(model)
    peak_infected = 0.0
    
    for step = 1:p[:n_steps]
        Agents.step!(model, 1)
        frac = infected_fraction(model)
        if frac > peak_infected
            peak_infected = frac
        end
    end
    
    final_infected = infected_fraction(model)
    final_recovered = count(a.status == :R for a in allagents(model)) / nagents(model)
    total_deaths = sum(p[:Ns]) - nagents(model)
    
    return (
        peak = peak_infected,
        final_inf = final_infected,
        final_rec = final_recovered,
        deaths = total_deaths,
    )
end

# Диапазон значений beta (скаляр)
beta_range = 0.1:0.1:1.0
seeds = [42, 43, 44]
n_steps = 100

# Создаём список параметров
params_list = []
for b in beta_range
    for s in seeds
        push!(params_list, Dict(
            :beta => b,
            :Ns => [1000, 1000, 1000],
            :infection_period => 14,
            :detection_time => 7,
            :death_rate => 0.02,
            :reinfection_probability => 0.1,
            :Is => [0, 0, 1],
            :seed => s,
            :n_steps => n_steps,
        ))
    end
end

# Создаём директории
mkpath(datadir())
mkpath(plotsdir())

# Запуск экспериментов
println("Запуск параметрического сканирования...")
println("Всего экспериментов: $(length(params_list))")
results = []

for (i, params) in enumerate(params_list)
    data = run_experiment(params)
    push!(results, merge(params, Dict(pairs(data))))
    println("  [$i/$(length(params_list))] beta = $(params[:beta]), seed = $(params[:seed])")
end

# Сохраняем все прогоны
df = DataFrame(results)
CSV.write(datadir("beta_scan_all.csv"), df)
println("\n✅ Данные сохранены: $(datadir("beta_scan_all.csv"))")

# Усреднение по повторам
grouped = combine(groupby(df, [:beta]),
    :peak => mean => :mean_peak,
    :final_inf => mean => :mean_final_inf,
    :deaths => mean => :mean_deaths,
)

# График
println("Построение графика...")
plot(grouped.beta, grouped.mean_peak, 
     label = "Пик эпидемии", 
     xlabel = "Коэффициент заразности β", 
     ylabel = "Доля инфицированных", 
     marker = :circle, 
     linewidth = 2,
     color = :red)

plot!(grouped.beta, grouped.mean_final_inf, 
      label = "Конечная доля инфицированных", 
      marker = :square, 
      linewidth = 2,
      color = :blue)

plot!(grouped.beta, grouped.mean_deaths ./ 3000, 
      label = "Доля умерших", 
      marker = :diamond, 
      linewidth = 2,
      color = :black)

title!("Зависимость эпидемических показателей от β")
savefig(plotsdir("beta_scan.png"))

println("✅ График сохранён: $(plotsdir("beta_scan.png"))")
