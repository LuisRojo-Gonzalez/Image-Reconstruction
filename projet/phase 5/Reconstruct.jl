# include required libraries
include("../phase 1/read_stsp.jl")
include("../phase 4/RSL_module.jl")
include("../phase 4/LK_module.jl")
include("shredder-julia/bin/tools.jl")

function reconstruct(filename::String, TOUR_ALGO::Function, READ::String, STEP::Vector{Float64}(undef, 2), ADAPT::Bool, RAND_ROOT::Bool, TL::Int, ALGO::Function)
    g = build_graph(PROJECT_PATH * "/phase 5/shredder-julia/tsp/instances/$(filename).tsp")
    # ------------------------------------------------------------------ #
    # ------------------------ compute the tour ------------------------ #
    # ------------------------------------------------------------------ #
    ###### using RSL ########
    if TOUR_ALGO == "RSL"

        println("Checking ineg")
        trig_ineg = has_triang_ineg(g)
        @show trig_ineg
        if trig_ineg
            root = nodes(g)[rand(1:nb_nodes(g))]
            tour_rsl, cost_rsl, time_rsl = rsl(g, root , ALGO, trig_ineg; TL = TL)
            tour_nodes = parcours_postordre!(tour_rsl, root)
            @show data.(tour_nodes)
            tour_rsl_array =  data.( tour_nodes)

        # export the tour
            write_tour(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_rsl_$(ALGO)_$(TL).tour", tour_rsl_array, score_picture(PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png"))

        # create the reconstructed image from the tour
            reconstruct_picture(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_rsl_$(ALGO)_$(TL).tour", PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png",
            PROJECT_PATH * "/phase 5/shredder-julia/images/reconstructed/$(filename)_rsl_$(ALGO)_$(TL).png"; view = true)
        end
        ######## using LK ########
    elseif TOUR_ALGO == "HK"
        println("starting HK")

        tour_lk, cost_lk, is_tour_lk, time_lk , tour_comp_lk, graph_modified_weight = lk(g, ALGO, get_node(g,"1"), 1000, TL, STEP, ADAPT, RAND_ROOT)
        if !is_tour_lk
            if READ == "pre"
                tour_nodes = parcours_preordre!(tour_lk, get_node(tour_lk, "1"))
            end
            tour_lk_array =  parse.(Int, name.(tour_nodes)) .-1
            # i = findall(x -> x == 601, tour_lk_array)
            # deleteat!(tour_lk_array, i)
            @show length(tour_lk_array)
        else
            tour_lk_array = Vector{Int}()
            neigh = get_all_neighbours(tour_lk, get_node(g, "1"))
            tour_lk_array = parcours_cycle(tour_lk) .-1
        end

        #our_weight = get_weight_of(g, tour_lk_array)
        #@show tour_weight

        # export the tour
        write_tour(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_lk_$(STEP)_$(ADAPT)_$(ALGO)_$(READ)_$(TL)_$(RAND_ROOT).tour", tour_lk_array, score_picture(PROJECT_PATH * "/phase 5/shredder-julia/images/original/$(filename).png"))
       # PROJECT_PATH * "/phase 5/shredder-julia/images/reconstructed/$(filename)_lk_$(STEP)_$(ADAPT)_$(ALGO)_$(READ)_$(TL)_$(RAND_ROOT).png"; view = true)))
        # create the reconstructed image from the tour
        reconstruct_picture(PROJECT_PATH * "/phase 5/shredder-julia/tsp/tours/$(filename)_lk_$(STEP)_$(ADAPT)_$(ALGO)_$(READ)_$(TL)_$(RAND_ROOT).tour", PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png",
        PROJECT_PATH * "/phase 5/shredder-julia/images/reconstructed/$(filename)_lk_$(STEP)_$(ADAPT)_$(ALGO)_$(READ)_$(TL)_$(RAND_ROOT).png"; view = true)
    end
end
