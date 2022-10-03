# Julia evaluation in plain markdown

[Julia in VS Code - What's New](https://youtu.be/Okn_HKihWn8?t=1077)

```julia
who = "JuliaCon2022"
println("Hello, $who")
```

Also try enabling `julia.execution.inlineResultsForCellEvaluation`
```julia
using Markdown
this = read(@__FILE__, String)
Markdown.parse(this)
```
