using DrWatson
@quickactivate "project"
using DataFrames, CSV, Plots

df_det = CSV.read(datadir("sir_det.csv"), DataFrame)
df_stoch = CSV.read(datadir("sir_stoch.csv"), DataFrame)
df_scan = CSV.read(datadir("sir_scan.csv"), DataFrame)

# Сравнение детерминированной и стохастической динамики
p1 = plot(
    df_det.time,
    [df_det.I df_stoch.I[1:length(df_det.time)]],
    label = ["Deterministic I" "Stochastic I"],
    xlabel = "Time",
    ylabel = "Infected",
    title = "Comparison of Deterministic and Stochastic Dynamics",
)
savefig(plotsdir("comparison.png"))

# Зависимость пика I от β
p2 = plot(
    df_scan.β,
    df_scan.peak_I,
    marker = :circle,
    xlabel = "β",
    ylabel = "Peak I",
    title = "Sensitivity to β",
)
savefig(plotsdir("sensitivity.png"))

# Тепловая карта для параметрического исследования (β, γ)
β_vals = 0.1:0.05:0.8
γ_vals = 0.05:0.02:0.2
peak_matrix = zeros(length(β_vals), length(γ_vals))

for (i, β) in enumerate(β_vals)
    for (j, γ) in enumerate(γ_vals)
        net, u0, _ = build_sir_network(β, γ)
        df = simulate_deterministic(net, u0, (0.0, 100.0), saveat = 0.5, rates = [β, γ])
        peak_matrix[i, j] = maximum(df.I)
    end
end

p3 = heatmap(
    γ_vals,
    β_vals,
    peak_matrix,
    xlabel = "γ (recovery rate)",
    ylabel = "β (infection rate)",
    title = "Peak I as function of β and γ",
    colorbar = true,
)
savefig(plotsdir("heatmap.png"))

println("Отчётные графики сохранены в plots/")
