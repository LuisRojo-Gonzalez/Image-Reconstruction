# get the optimal tour

using TravelingSalesmanExact, Gurobi

# include required libraries
include("../phase 1/graph.jl")
include("../phase 4/RSL_module.jl")
include("../phase 4/LK_module.jl")
include("shredder-julia/bin/tools.jl")
const PROJECT_PATH = "/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet"
filename = "blue-hour-paris"#ARGS[2]
picture = load(PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png")


####### LK PARAM ###################################

const STEP = [1.0, 1.0]
const ADAPT = true
const RAND_ROOT = true
const TL = 300
#const ALGO = kruskal
####################################################

g = Graph{Int}(filename, Vector{Node}(), Vector{Edge}())

for i in 1:size(picture, 2)
    add_node!(g, Node(string(i), i))
end


    # add –fake– node as a source
    add_node!(g, Node("s", 0))

    # considers each column as a node
    for i in 1:size(picture, 2)
        # add the zero weight from the -fake- source to each node
        add_edge!(g, Edge((get_node(g, "s"), get_node(g, string(i))), 0.0))

        # the the edge to between other nodes
        for j in i:size(picture, 2)
            # compute the weight of the edge and add the edge
            # as the matrix is symmetric, then skip the lower triangular matrix as well as the diagonal
            computed_weight = convert(Float64,compare_columns(picture[:,i], picture[:,j]))
                # add the edge
            add_edge!(g, Edge((get_node(g,string(i) ), get_node(g, string(j))), computed_weight))
        end
    end




set_default_optimizer!(Gurobi.Optimizer)

#cities = [100*rand(2) for _ in 1:length(nodes(g))]

cost_matrix = zeros(length(nodes(g)), length(nodes(g)))

for edge in edges(g)
    n1, n2 = ends(edge)
    if data(n1) == data(n2)
        cost_matrix[data(n1) + 1, data(n2) + 1] = 0.0
    else
        cost_matrix[data(n1) + 1, data(n2) + 1] = weight(edge)
        cost_matrix[data(n2) + 1, data(n1) + 1] = weight(edge)
    end
end


tour, cost = get_optimal_tour(cost_matrix, verbose = true)
@show cost
index_start = findfirst(x -> x == 1, tour)
#deleteat!(tour, index_start)
tour_out = Vector{Int64}()
for i in index_start+1 : 601
    push!(tour_out, tour[i] - 1)
end
for i in 1:index_start - 1
    push!(tour_out, tour[i]  -1 )
end
@show size(tour_out)
@show minimum(tour_out), maximum(tour_out)
# @show tour_out

#tour_weight = get_weight_of(g, tour_out)
#@show tour_weight
write_tour(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_optimal.tour", tour_out, score_picture(PROJECT_PATH * "/phase 5/shredder-julia/images/original/$(filename).png"))
reconstruct_picture(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_optimal.tour", 
PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png",
PROJECT_PATH * "/phase 5/shredder-julia/images/reconstructed/$(filename)_optimal.png"; view = true)
