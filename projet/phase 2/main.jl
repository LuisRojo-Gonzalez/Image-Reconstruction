
include("../phase 1/read_stsp.jl")
include("./connex_componant.jl")



filename = ARGS[1]
graph = build_graph("../../instances/stsp/$(filename).tsp")
tree = kruskal(graph)
for g in [graph, tree]
    println("Sum of all edges weight in $(name(g)): $(sum(weight.(edges(g))))")
end

