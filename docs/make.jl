using FMSynth
using Documenter

makedocs(;
    modules=[FMSynth],
    authors="Simeon Schaub <simeondavidschaub99@gmail.com> and contributors",
    repo="https://github.com/simeonschaub/FMSynth.jl/blob/{commit}{path}#L{line}",
    sitename="FMSynth.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://simeonschaub.github.io/FMSynth.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/simeonschaub/FMSynth.jl",
)
