include("../phase 1/read_stsp.jl")
include("RSL_module.jl")
include("LK_module.jl")
include("MST_module.jl")
using Random
using DataFrames, CSV

const SEED = 42

files_override_loop = [ARGS[1]]
instances_folder = joinpath("..", "..", "instances", "stsp")
for (root, dirs, files) in walkdir(joinpath("..", "..", "instances", "stsp"))

    for f in files_override_loop ## remplacer par files pour lancer le main sur toutes les instances
        instance = chop(f, tail=4)
        Random.seed!(SEED) # set the seed for the random number generator

        file = joinpath(instances_folder, f)
        algorithms = [kruskal, prim]
        step = [1.0, 2.0]
        adaptive = [false, true]
        ## politique de choix de la racne:
        ## - 1: premier node du vecteur de noeuds du graphe
        ## - 2: choisi au hasard
        ## - 3: Noeud de degre le plus bas
        strat_choose_root = [1, 2, 3]


        grid_lk = allcombinations(DataFrame, algo=algorithms, step=step, adapt=adaptive, root_strat=strat_choose_root)
        grid_rsl = allcombinations(DataFrame, algo=algorithms, root_strat=strat_choose_root)

        # create the object to save the results

        results_lk = DataFrame(Root=Int[], Algorithm=Function[], Step=Float64[], Adaptive=Bool[], Tour=Bool[], Costs=Float64[], Time=[])
        results_rsl = DataFrame(Root=Int[], Algorithm=Function[], Trig = Bool[], Costs=Float64[], Time=[])


        ### ----- Test Loop for RSL ------- ##
        println("---- Solving instance $(instance) with RSL----")
        graph = build_graph(file)
        trig_ineg = has_triang_ineg(graph)
        for param in eachrow(grid_rsl)

            
            root = nodes(graph)[1]
            if param[:root_strat] == 1
                root = nodes(graph)[1]
            elseif param[:root_strat] == 2
                root = nodes(graph)[rand(1:nb_nodes(graph))]
            elseif param[:root_strat] == 3
                root = nodes(graph)[max_degre(graph)]
            end

            graph_tour_rsl, cost_rsl, time_rsl = rsl(graph, root, param[:algo], trig_ineg)

            # create mst with different techniques and add the times to the results object
            push!(results_rsl, [param[:root_strat], param[:algo], trig_ineg, cost_rsl, time_rsl], promote=true)
        end
        ## write results
        CSV.write(joinpath("results", "$(instance)_rsl.csv"), results_rsl)

        # ### ----- Test Loop for LK ------- ##
        println("---- Solving instance $(instance) with LK----")
        for param in eachrow(grid_lk)
            graph = build_graph(file)
            # apply the algorithm to find the tour

            root = nodes(graph)[1]
            if param[:root_strat] == 1
                root = nodes(graph)[1]
            elseif param[:root_strat] == 2
                root = nodes(graph)[rand(1:nb_nodes(graph))]
            elseif param[:root_strat] == 3
                root = nodes(graph)[max_degre(graph)]
            end
            solution, cost_lk, tour, time_lk = lin_kernighan(graph, param[:algo], root, 1000, 60, [param[:step], param[:step] + 1], param[:adapt])

            # create mst with different techniques and add the times to the results object
            push!(results_lk, [param[:root_strat], param[:algo], param[:step], param[:adapt], tour, cost_lk, time_lk])
        end
        ## write results
        CSV.write(joinpath("results", "$(instance)_lk.csv"), results_lk)

    end
end