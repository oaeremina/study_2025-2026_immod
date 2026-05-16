using DrWatson
@quickactivate "project"

println("Проверка путей DrWatson:")
println("Корень проекта: ", projectdir())
println("Каталог src: ", srcdir())
println("Каталог scripts: ", scriptsdir())
println("Каталог data: ", datadir())
println("Каталог plots: ", plotsdir())

println("\nПроверка наличия файла модели:")
model_path = joinpath(srcdir(), "daisyworld.jl")
if isfile(model_path)
    println("✓ Файл модели найден: $model_path")
else
    println("✗ Файл модели НЕ найден: $model_path")
end

println("\nЗагрузка пакетов...")
using Agents, DataFrames, Plots, CairoMakie, Statistics
println("✓ Все пакеты загружены успешно")

println("\nПроверка завершена!")

