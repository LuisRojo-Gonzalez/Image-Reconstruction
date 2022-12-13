
include("../phase 1/read_stsp.jl")
include("./prim.jl")
include("./heuristic1.jl")
include("heuristic2.jl")

using BenchmarkTools



filename = ARGS[1]
io = IOContext(stdout, :histmin=>0.5, :histmax=>8, :logbins=>true)
graph = build_graph("../../instances/stsp/$(filename).tsp")


println("\n kruskal")
tree_kruskal= kruskal(graph)
println("Poids: ", sum(weight.(edges(tree_kruskal))))
b = @benchmark kruskal(graph)
show(io, MIME("text/plain"), b)



println("\n kruskal_heuristique 1")
tree_kruskal_heur = kruskal_heur1(graph)
println("Poids: ", sum(weight.(edges(tree_kruskal_heur))))
b = @benchmark kruskal_heur1(graph)
show(io, MIME("text/plain"), b)


println("\n kruskal_heuristique 2")
tree_kruskal_heur2 = kruskal_heur2(graph)
println("Poids: ", sum(weight.(edges(tree_kruskal_heur2))))
b = @benchmark kruskal_heur2(graph)
show(io, MIME("text/plain"), b)


println("\n Prim:")
tree_prim = prim(graph)
println("Poids: ", sum(weight.(edges(tree_prim))))
b = @benchmark prim(graph)
show(io, MIME("text/plain"), b)
# readline()