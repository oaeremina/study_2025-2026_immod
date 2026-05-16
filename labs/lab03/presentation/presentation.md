---
## Front matter
lang: ru-RU
title: Лабораторная работа №3
subtitle: "Агентное моделирование"
author:
  - Еремина О. А.
institute:
  - Российский университет дружбы народов, Москва, Россия
date: 20 марта 2026

## i18n babel
babel-lang: russian
babel-otherlangs: english

## Formatting pdf
toc: false
toc-title: Содержание
slide_level: 2
aspectratio: 169
section-titles: true
theme: metropolis
header-includes:
 - \metroset{progressbar=frametitle,sectionpage=progressbar,numbering=fraction}
 - \usepackage{fontspec}
 - \setmainfont{FreeSerif}
 - \setsansfont{FreeSans}
 - \setmonofont{FreeMono}
 - \usepackage{polyglossia}
 - \setmainlanguage{russian}
 - \setotherlanguage{english}
---

## Докладчик

:::::::::::::: {.columns align=center}
::: {.column width="70%"}

  * Еремина Оксана Андреевна
  * студентка
  * группа НКНбд-01-23
  * Российский университет дружбы народов
  * [1132236056@rudn.ru](mailto:1132236056@rudn.ru)
  * <https://github.com/oaeremina>

:::
::: {.column width="30%"}

:::
::::::::::::::


# 1. Цель работы
Изучить модель гармонического осциллятора, исследовать три режима колебаний (без затухания, с затуханием, вынужденные колебания), освоить методы решения дифференциальных уравнений в Julia и параметрический анализ.


---

# 2. Этапы выполнения

### 2.1 Базовая визуализация

На рис. 1-3 представлена визуализация модели на разных шагах симуляции.

![Начальное состояние (шаг 0)](../project/plots/daisy_step000.png){#fig:step1 width=70%}

![После 5 итераций (шаг 5)](../project/plots/daisy_step005.png){#fig:step5 width=70%}

![После 40 итераций (шаг 40)](../project/plots/daisy_step040.png){#fig:step45 width=70%}

# 2. Этапы выполнения

### 2.2 Анализ численности маргариток

На рис. 4 представлена динамика численности черных и белых маргариток.

![Динамика численности маргариток](../project/plots/daisy_population_dynamics.png){#fig:count width=100%}

# 2. Этапы выполнения

### 2.3 Влияние солнечной активности

На рис. 5 представлено влияние солнечной активности на динамику модели.

![Влияние солнечной активности (сценарий ramp)](../project/plots/daisy_luminosity_ramp.png){#fig:luminosity-ramp width=100%}

![Влияние солнечной активности (сценарий change)](../project/plots/daisy_luminosity_change.png){#fig:luminosity-change width=100%}

# 2. Этапы выполнения

### Исследование 1: Базовая параметрическая визуализация

![Параметрическое исследование (max_age=25, init_white=0.2)](../project/plots/daisyworld_param/daisyworld_param_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.2_max_age=25_scenario=default_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:param1 width=100%}

![Параметрическое исследование (max_age=25, init_white=0.8)](../project/plots/daisyworld_param/daisyworld_param_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.8_max_age=25_scenario=default_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:param2 width=100%}

![Параметрическое исследование (max_age=40, init_white=0.2)](../project/plots/daisyworld_param/daisyworld_param_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.2_max_age=40_scenario=default_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:param3 width=100%}

![Параметрическое исследование (max_age=40, init_white=0.8)](../project/plots/daisyworld_param/daisyworld_param_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.8_max_age=40_scenario=default_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:param4 width=100%}

# 2. Этапы выполнения

### Исследование 2: Параметрическое исследование численности

Графики для различных комбинаций параметров представлены на рис. 6-9.

![Численность (max_age=25, init_white=0.2)](../project/plots/daisyworld-count_param/daisy-count_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.2_max_age=25_scenario=default_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:count1 width=100%}

![Численность (max_age=25, init_white=0.8)](../project/plots/daisyworld-count_param/daisy-count_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.8_max_age=25_scenario=default_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:count2 width=100%}

![Численность (max_age=40, init_white=0.2)](../project/plots/daisyworld-count_param/daisy-count_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.2_max_age=40_scenario=default_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:count3 width=100%}

![Численность (max_age=40, init_white=0.8)](../project/plots/daisyworld-count_param/daisy-count_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.8_max_age=40_scenario=default_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:count4 width=100%}

# 2. Этапы выполнения

#### Исследование 3: Комплексное параметрическое исследование

![Комплексное (max_age=25, init_white=0.2)](../project/plots/daisyworld-luminosity_param/daisy-luminosity_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.2_max_age=25_scenario=ramp_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:lumi1 width=100%}

![Комплексное (max_age=25, init_white=0.8)](../project/plots/daisyworld-luminosity_param/daisy-luminosity_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.8_max_age=25_scenario=ramp_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:lumi2 width=100%}

![Комплексное (max_age=40, init_white=0.2)](../project/plots/daisyworld-luminosity_param/daisy-luminosity_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.2_max_age=40_scenario=ramp_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:lumi3 width=100%}

![Комплексное (max_age=40, init_white=0.8)](../project/plots/daisyworld-luminosity_param/daisy-luminosity_albedo_black=0.25_albedo_white=0.75_init_black=0.2_init_white=0.8_max_age=40_scenario=ramp_seed=165_solar_change=0.005_solar_luminosity=1.0_surface_albedo=0.4.png){#fig:lumi4 width=100%}

# 2. Этапы выполнения

### 2.7. Создание отчёта
- Создан файл `report.qmd` со всеми графиками
- Добавлен список литературы (6 источников)
- Отчёт скомпилирован в PDF

# 2. Этапы выполнения

### 2.8. Отправка на GitVerse
- Код отправлен в репозиторий
- Создан релиз `lab01-v56` с отчётом и графиками

---


# 3. Выводы

В ходе выполнения лабораторной работы:

1. Была изучена парадигма агентного моделирования.
2. Реализована агентная модель Daisyworld.
3. Проведён анализ динамики системы при различных параметрах.
4. Созданы литературные скрипты и сгенерированы производные форматы.
5. Подготовлен отчёт в формате PDF.
