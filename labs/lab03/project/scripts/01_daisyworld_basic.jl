using DrWatson
@quickactivate "project"
using Agents, Plots, CairoMakie

include(joinpath(srcdir(), "daisyworld.jl"))

println("Создание модели...")
model = daisyworld()

daisycolor(a::Daisy) = a.breed == :white ? :white : :black

plotkwargs = (
    agent_color=daisycolor,
    agent_size=20,
    agent_marker='✿',
    heatarray=:temperature,
    heatkwargs=(colorrange=(-20, 60),)
)

println("Создание визуализации...")

plt1, _ = abmplot(model; plotkwargs...)
save(plotsdir("daisy_step_000.png"), plt1)
println("✓ Шаг 0 сохранен")

step!(model, 5)
plt2, _ = abmplot(model; plotkwargs...)
save(plotsdir("daisy_step_005.png"), plt2)
println("✓ Шаг 5 сохранен")

step!(model, 35)
plt3, _ = abmplot(model; plotkwargs...)
save(plotsdir("daisy_step_040.png"), plt3)
println("✓ Шаг 40 сохранен")

println("\nГотово! Графики сохранены в каталоге plots/")
