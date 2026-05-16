.PHONY: all setup run report clean

all: setup run report

setup:
	@echo "Установка зависимостей..."
	julia -e 'using Pkg; Pkg.activate("project"); Pkg.instantiate()'

run:
	@echo "Запуск базовой визуализации..."
	julia --project=project scripts/01_daisyworld_basic.jl
	@echo "Запуск анализа популяции..."
	julia --project=project scripts/02_daisyworld_count.jl
	@echo "Запуск анализа светимости..."
	julia --project=project scripts/03_daisyworld_luminosity.jl
	@echo "Запуск параметрического анализа..."
	julia --project=project scripts/05_daisyworld_parametric.jl

report:
	@echo "Генерация отчетов..."
	julia --project=project scripts/tangle.jl scripts/01_daisyworld_basic.jl
	julia --project=project scripts/tangle.jl scripts/02_daisyworld_count.jl
	julia --project=project scripts/tangle.jl scripts/03_daisyworld_luminosity.jl

clean:
	@echo "Очистка..."
	rm -rf project/data/*
	rm -rf project/plots/*
	rm -rf project/markdown/*
	rm -rf project/notebooks/*
