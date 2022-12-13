# include required libraries
include("../phase 1/graph.jl")
include("../phase 4/RSL_module.jl")
include("../phase 4/LK_module.jl")


g = test_graph_complet()
root = nodes(g)[1]
tree, comp, r = get_one_tree(g, kruskal, root)
@show nb_edges(tree)