# docs/make.jl
using Documenter
using OMOPVocabMapper  # Replace with your package name

makedocs(
    sitename = "OMOPVocabMapper.jl",  # Replace with your package name
    modules = [OMOPVocabMapper],
    clean = true,
)

deploydocs(
    repo = "github.com/mounika-thakkallapally/OMOPVocabMapper.jl.git",  # Replace with your repository URL
    branch = "gh-pages",
    target = "build",
)
