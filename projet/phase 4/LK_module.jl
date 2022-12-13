
import Base.isequal
using Random
include("MST_module.jl")

"""
Takes as parameters a graph, an algorithm for MST, a root (or nothing in whose case the root is randomly selected at each iteration),
iteration limit, time limit, step size as a vector of two numbers to bound the random number generator, an adaptive as a boolean to indicate whether
the step size update uses a fraction (0.3) of the previous result. It returns the best solution found as a graph, its cost, whether it is a tour
and the elapsed time it took.
"""
function lk(graph::Graph{T}, algorithm::Function, root::Union{Nothing, Node{T}},  max_iterations::Int64, max_time::Int64, step::Vector{Float64}, adaptive::Bool, rand_root::Bool) where T
    # clocks the time
    starting_time = time()
    elapsed_time = time() - starting_time
    one_tree = Graph{T}("1tree", Vector{Node{T}}(), Vector{Edge{T}}())
    modified_graph = Graph{T}("tmp", deepcopy(nodes(graph)), deepcopy(edges(graph)))
    tree_comp = Component{T}()
    tree_cost = 0
    dual_cost = 0

    period = floor(length(nodes(graph)) / 2)
    period_counter = 0
    is_first_period = true
    is_step_size_doubled = false


    # creates a dictionary that indicates the degree of each node in the 1-tree
    dict_pi = Dict{String, Float64}()
    for n in nodes(modified_graph)
        dict_pi[name(n)] = 0.0
    end

    # creates a dictionary that represents the difference of degree with a tour
    graph_degree = Dict{String, Float64}()
    graph_degree_prev = Dict{String, Float64}()
    for n in nodes(modified_graph)
        graph_degree[name(n)] = 0.0
        graph_degree_prev[name(n)] = 0.0
    end

     # tracks the improvement over the cost function
     incumbent = [-Inf, -Inf] # starting lower bound, where [1] is at iteration (i-th - 1) and [2] at iteration (i-th)

     # initial step size
     step_size = step[1] == step[2] ? step[1] : rand(step[1]:0.1:step[2])
 
     # initialize the counter for the iterations
     iter = 1
 
     # the tour indicador is set to be false
     is_tour = false

     while iter <= max_iterations && elapsed_time <= max_time

        println("-----------------------------------------------------------------------------------------------------------")
        println("--- Iteration: $(iter) | Elapsed time (s): $(round(elapsed_time; digits = 4)) | Incumbent: $(incumbent[2]) ---")
        println("-----------------------------------------------------------------------------------------------------------")
        for i in 1:nb_edges(modified_graph)
            edge = edges(modified_graph)[i]
            n1, n2 = ends(edge)
            og_weight = weight(edges(graph)[i])
            set_weight!(edge, og_weight + dict_pi[name(n1)] + dict_pi[name(n2)])
        end
        # construct the 1-tree and the degree of the nodes
        artificial_cost = 0
        elapsed_time = time() - starting_time
        if isnothing(root) || (rand_root && (iter < max_iterations -2 || elapsed_time < max_time - 10))
            root_tmp = nodes(modified_graph)[rand(1:nb_nodes(modified_graph))]
            one_tree, tree_comp, root_tmp = get_one_tree(modified_graph, algorithm, root_tmp)
            artificial_cost = sum(weight.(get_all_edges_with_node(one_tree, get_node(one_tree, name(root_tmp)))))
        else
            one_tree, tree_comp, root_tmp = get_one_tree(modified_graph, algorithm, root)
            artificial_cost = sum(weight.(get_all_edges_with_node(one_tree, get_node(one_tree, name(root)))))
        end
        # compute the total cost of the 1-tree
        tree_cost = sum(weight.(edges(one_tree)))
        
        @show tree_cost
        @show tree_cost - artificial_cost
        # compute the lagrangian
        dual_cost = tree_cost - 2*sum(values(dict_pi))

        # update the incumbent to save the two previous results
        incumbent[1] = incumbent[2]
        incumbent[2] = max(incumbent[2], dual_cost)

        # getting the difference with a degree of 2
        degrees_iter = Vector{Int}()
        if !adaptive
            # graph_degree[root] = degree(tree_comp, root) - 2
            # graph_degree_prev[root] = graph_degree_prev[root]
            
            for n in nodes(one_tree)
                d = get_degree(one_tree, n)
                push!(degrees_iter, d)
                graph_degree[name(n)] = d - 2
                graph_degree_prev[name(n)] = graph_degree_prev[name(n)]
            end
            @show sum(collect(values(graph_degree)) .> 0)

        else
            
            if iter == 1
                # @show length(collect(keys(degrees(tree_comp))))
                for n in nodes(g)
                    d = get_degree(one_tree, n)
                    push!(degrees_iter, d)
                     graph_degree[name(n)] = d - 2
                     graph_degree_prev[name(n)] = graph_degree_prev[name(n)]
                end
            else
                # @show length(collect(keys(degrees(tree_comp))))
                for n in nodes(g)
                    d = get_degree(one_tree, n)
                    push!(degrees_iter, d)
                     graph_degree_prev[name(n)] = graph_degree[name(n)]
                     graph_degree[name(n)] = d - 2
                end
            end
        end

        @show length(findall(degrees_iter .== 2))
        # check for a tour
        if all(degrees_iter .== 2) #|| period == 0 || step_size == 0
            tree_cost = 0
            # here we should get the original weights in the tree
            for edge in edges(one_tree)
                n1, n2 = ends(edge)
                tree_cost += weight(get_edge(graph, get_node(graph, name(n1)), get_node(graph, name(n2))))
            end

        
            println("---------------------------------------------")
            println("----- A Hamiltonian tour has been found -----")
            println("---- The tour found has cost $(tree_cost) ----")
            println("---------------------------------------------")
            # indicator to check whether the solution is a tour
            is_tour = true
      
            # updates the time
            elapsed_time = time() - starting_time

            return one_tree, tree_cost, is_tour, elapsed_time, tree_comp, graph
        end


         # update the step size
         step_size = rand(step[1]:0.1:step[2]) / iter
         period_counter = period_counter + 1 # increase the counter

         # if we are at the first period and the incumbent has not impreved
         if is_first_period && (incumbent[2] <= incumbent[1]) && !is_step_size_doubled
             is_step_size_doubled = true
             step_size = step_size * 2 
         else
          #  if in the last iteration the incumbent gets improved
            if period_counter == period && (incumbent[1] < incumbent[2])
                 step_size = step_size * 2 
                 period = floor(period * 2)
                 is_first_period = false # the forward iterations are no longer within the first period
             elseif period_counter <= period
                 step_size = step_size
             else
                 period_counter = 0 # reinitialize the period counter
                 step_size = step_size / 2
                 period = floor(period / 2)
             end
         end

        @show step_size, period_counter, period

         if step_size == 0 || period == 0
             break
         end


        for n in nodes(one_tree)
             dict_pi[name(n)] = dict_pi[name(n)] + step_size * (0.7*graph_degree[name(n)] + 0.3*graph_degree_prev[name(n)])
            #dict_pi[name(n)] = dict_pi[name(n)] + step_size * graph_degree[name(n)]
        end
        # increase the counter
        iter = iter + 1

        # updates the time
        elapsed_time = time() - starting_time
    end

    #### now it actually print out according to the progress and not when going out of the loop
    if !is_tour
        println("----------------------------------------------------")
        println("------ A Hamiltonian tour has not been found -------")
        println("-------- Best lower bound costs $(incumbent[2]) -------")
        println("----------------------------------------------------")
        tree_cost = incumbent[2]
    end
    
    return one_tree, tree_cost, is_tour, elapsed_time, tree_comp, graph
end

function lin_kernighan(graph::Graph{T}, algorithm::Function, root::Union{Nothing, Node{T}}, max_iterations::Int64, max_time::Int64, step::Vector{Float64}, adaptive::Bool, rand_root::Bool) where T
  
    # clocks the time
    starting_time = time()
    elapsed_time = time() - starting_time
    
    # creates starting objects to iteratively modify them
    one_tree = Graph{T}("1tree", Vector{Node{T}}(), Vector{Edge{T}}())
    root_tmp = Node{T}("", 0)
    tree_comp = Component{T}()
    tree_cost = 0
    dual_cost = 0
    period = 10#floor(length(nodes(graph)) / 2)
    period_counter = 0
    is_first_period = true
    is_step_size_doubled = false

    # creates a dictionary that indicates the degree of each node in the 1-tree
    dict_pi = Dict{Node{T}, Float64}()
    for n in nodes(graph)
        dict_pi[n] = 0.0
    end

    # creates a dictionary that represents the difference of degree with a tour
    graph_degree = Dict{Node, Float64}()
    graph_degree_prev = Dict{Node, Float64}()
    for n in nodes(graph)
    
        graph_degree[n] = 0.0
        graph_degree_prev[n] = 0.0
    end

    # create a dictionary with the original weights
    og_weights = Dict{Edge, Float64}()
    for e in edges(graph)
        og_weights[e] = weight(e)
    end

    # tracks the improvement over the cost function
    incumbent = [-Inf, -Inf] # starting lower bound, where [1] is at iteration (i-th - 1) and [2] at iteration (i-th)

    # initial step size
    step_size = step[1] == step[2] ? step[1] : rand(step[1]:0.1:step[2])

    # initialize the counter for the iterations
    iter = 1

    # the tour indicador is set to be false
    is_tour = false
    
    while iter <= max_iterations && elapsed_time <= max_time

        println("-----------------------------------------------------------------------------------------------------------")
        println("--- Iteration: $(iter) | Elapsed time (s): $(round(elapsed_time; digits = 4)) | Incumbent: $(incumbent[2]) ---")
        println("-----------------------------------------------------------------------------------------------------------")

        for edge in edges(graph)
            # get the ends of the edge
            n1, n2 = ends(edge)
            set_weight!(edge, og_weights[edge] + dict_pi[n1] + dict_pi[n2])
        end
        
        # construct the 1-tree and the degree of the nodes
        elapsed_time = time() - starting_time
        if isnothing(root) || rand_root && (iter < max_iterations || elapsed_time <= max_time - 10)
            root_tmp = nodes(graph)[rand(1:nb_nodes(graph))]
            # @show root_tmp
            one_tree, tree_comp, root_tmp = get_one_tree(Graph{T}("", nodes(graph), copy(edges(graph))), algorithm, root_tmp)
            
        else
            one_tree, tree_comp, root_tmp = get_one_tree(Graph{T}("", nodes(graph), copy(edges(graph))), algorithm, root)
        end

        # compute the total cost of the 1-tree
        tree_cost = sum(weight.(edges(one_tree)))
        @show tree_cost
        # compute the lagrangian
        @show findfirst(collect(values(dict_pi)) != 0)
        dual_cost = tree_cost - 2*sum(values(dict_pi))

        # update the incumbent to save the two previous results
        incumbent[1] = incumbent[2]
        incumbent[2] = max(incumbent[2], dual_cost)

        # getting the difference with a degree of 2
        degrees_iter = Vector{Int}()
        if !adaptive
            # graph_degree[root] = degree(tree_comp, root) - 2
            # graph_degree_prev[root] = graph_degree_prev[root]
            
            for n in nodes(one_tree)
                d = get_degree(one_tree, n)
                push!(degrees_iter, d)
                graph_degree[n] = d - 2
                graph_degree_prev[n] = graph_degree_prev[n]
            end
            @show sum(collect(values(graph_degree)) .> 0)

        else
            
            if iter == 1
                # @show length(collect(keys(degrees(tree_comp))))
                for n in nodes(g)
                    d = get_degree(one_tree, n)
                    push!(degrees_iter, d)
                     graph_degree[n] = d - 2
                     graph_degree_prev[n] = graph_degree_prev[n]
                end
            else
                # @show length(collect(keys(degrees(tree_comp))))
                for n in nodes(g)
                    d = get_degree(one_tree, n)
                    push!(degrees_iter, d)
                     graph_degree_prev[n] = graph_degree[n]
                     graph_degree[n] = d - 2
                end
            end
        end

        # check for a tour
        if all(degrees_iter .== 2) #|| period == 0 || step_size == 0
            
            # here we should get the original weights in the tree
            for edge in edges(one_tree)

                # replace the weights
                set_weight!(edge, og_weights[edge])
            end

            # update the 1-tree cost
            tree_cost = sum(weight.(edges(one_tree)))
            println("---------------------------------------------")
            println("----- A Hamiltonian tour has been found -----")
            println("---- The tour found has cost $(tree_cost) ----")
            println("---------------------------------------------")
            # indicator to check whether the solution is a tour
            is_tour = true
      
            # updates the time
            elapsed_time = time() - starting_time

            return one_tree, tree_cost, is_tour, elapsed_time, tree_comp, graph
        end

        # # update the step size
        # # step_size = rand(step[1]:0.1:step[2]) / iter
        # period_counter = period_counter + 1 # increase the counter

        # # if we are at the first period and the incumbent has not impreved
        # if is_first_period && (incumbent[2] <= incumbent[1]) && !is_step_size_doubled
        #     is_step_size_doubled = true
        #     step_size = step_size * 2 
        # else
        #     # if in the last iteration the incumbent gets improved
        #     if period_counter == period && (incumbent[1] < incumbent[2])
        #         step_size = step_size * 2 
        #         period = floor(period * 2)
        #         is_first_period = false # the forward iterations are no longer within the first period
        #     elseif period_counter <= period
        #         step_size = step_size
        #     else
        #         period_counter = 0 # reinitialize the period counter
        #         step_size = step_size / 2
        #         period = floor(period / 2)
        #     end
        # end

        @show step_size, period_counter, period

        # if step_size == 0 || period == 0
        #     break
        # end

        # Update reduced costs

        for n in nodes(one_tree)
            # if step_size * (0.7*graph_degree[n] + 0.3*graph_degree_prev[n]) != 0
            #     println("HERE ---------------------------------------------------------------------------------------")
            #     @show n
            #     break
            # end
            dict_pi[n] = dict_pi[n] + step_size * (0.7*graph_degree[n] + 0.3*graph_degree_prev[n])
        end
        # increase the counter
        iter = iter + 1

        # updates the time
        elapsed_time = time() - starting_time
    end

    #### now it actually print out according to the progress and not when going out of the loop
    if !is_tour
        println("----------------------------------------------------")
        println("------ A Hamiltonian tour has not been found -------")
        println("-------- Best lower bound costs $(incumbent[2]) -------")
        println("----------------------------------------------------")
        tree_cost = incumbent[2]
    end
    
    return one_tree, tree_cost, is_tour, elapsed_time, tree_comp, graph
end
