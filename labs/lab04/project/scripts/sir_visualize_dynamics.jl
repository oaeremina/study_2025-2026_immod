using DrWatson
@quickactivate "project"
using DataFrames, Plots, CSV

# Загрузка данных
df = CSV.read(datadir("beta_scan_all.csv"), DataFrame)

# Построение графика
plot(df[df.seed .== 42, :beta], df[df.seed .== 42, :peak], 
     label = "Пик инфекции (seed=42)", 
     xlabel = "β", ylabel = "Доля", marker = :circle, linewidth = 2)

plot!(df[df.seed .== 42, :beta], df[df.seed .== 42, :final_inf], 
      label = "Финальная доля инфекции", marker = :square, linewidth = 2)

plot!(df[df.seed .== 42, :beta], df[df.seed .== 42, :deaths] ./ 3000, 
      label = "Доля умерших", marker = :diamond, linewidth = 2)

title!("Комплексный анализ")
savefig(plotsdir("comprehensive_analysis.png"))

println("Сводный график сохранен: plots/comprehensive_analysis.png")
