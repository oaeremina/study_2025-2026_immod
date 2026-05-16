using DrWatson
@quickactivate "project"
using Literate

function main()
    scripts = [
        "run_mmc.jl",
        "run_ross.jl"
    ]
    
    for script in scripts
        path = scriptsdir(script)
        if isfile(path)
            println("Обработка: $script")
            Literate.markdown(path, projectdir("markdown"); flavor=Literate.QuartoFlavor())
            Literate.notebook(path, projectdir("notebooks"))
            Literate.script(path, scriptsdir("clean"))
        end
    end
end

main()
