
mutable struct Tree{T} 
    node::Node{T}
    children::Vector{Tree{T}}
    parent::Union{Tree{T}, Missing}
end
node(t::Tree) = t.node
children(t::Tree) = t.children
parent(t::Tree) = t.parent

function rsl(g::Graph{T}, root::Node{T}, algorithm::Function, trig_ineg::Bool; TL = 120) where T
        # clocks the time

    starting_time = time()
    elapsed_time = time() - starting_time
    println("Inegalite triangulaire: $(trig_ineg)")
    if trig_ineg
       
        #calculer un arbre de recouvrement minimal 
        arbre_graph, composante = algorithm(g)
        @show nb_edges(arbre_graph)
        @show nb_edges(g)
        tree_structure = Tree{T}(root,  Vector{Tree{T}}(), missing)
        create_child!(arbre_graph, tree_structure, [root])

        tour_nodes = Vector{Node{T}}()
        parcours_preordre!(tree_structure, tour_nodes)
        tour_edges = Vector{Edge{T}}()
        for i in 1:(length(tour_nodes) - 1)
            if time() - starting_time > TL
                break
            end
            e = get_edge(g, Node{T}(name(tour_nodes[i]), data(tour_nodes[i])), Node{T}(name(tour_nodes[i+1]), data(tour_nodes[i+1])))
            if !(isnothing(e))
                push!(tour_edges, e)
            end
        end
        e = get_edge(g, Node{T}(name(tour_nodes[1]), data(tour_nodes[1])), Node{T}(name(tour_nodes[end]), data(tour_nodes[end])))
        if !(isnothing(e))
            push!(tour_edges, e)
        else
            println("Aucun tour n'a ete trouvé")
            elapsed_time = time() - starting_time
            return missing, missing, elapsed_time
        end
        poids = sum(weight.(tour_edges))
        println("Poids de la tournee: $(poids)")
        
        elapsed_time = time() - starting_time
        return Graph{T}("RSL_Tour de $(name(g))", nodes(g), tour_edges), poids, elapsed_time
    end
    elapsed_time = time() - starting_time
    return missing, missing, elapsed_time
end


function create_child!(g::Graph{T}, parent::Tree{T}, deja_la::Vector{Node{T}}) where T
    root = node(parent)
    for n in nodes(g)
        if isnothing( findfirst(x -> name(x)== name(n),deja_la)) && !isnothing(get_edge(g, root, n))
            new_item = Tree{T}(n, Vector{Tree{T}}(), parent)
            push!(deja_la, n)
            push!(children(parent), new_item)
        end
    end

    for c in children(parent)
        create_child!(g, c, deja_la)
    end

    parent
end

function parcours_preordre!(root::Tree{T}, tour_nodes::Vector{Node{T}}) where T
    isnothing(root) && return 
    push!(tour_nodes, node(root))
    for t in children(root)
        parcours_preordre!(t, tour_nodes)
    end
    tour_nodes
end

function parcours_postordre!(root::Tree{T}, tour_nodes::Vector{Node{T}}) where T
    isnothing(root) && return 
    
    for t in children(root)
        parcours_postordre!(t, tour_nodes)
    end
    push!(tour_nodes, node(root))
    tour_nodes
end


"""
Renvoi true si l'inégalité triangulaire est vérifiée dans un graphe g , false sinon
"""
function has_triang_ineg(g::Graph{T}) where T
   resultats = Vector{Bool}()
   for e in edges(g)
       (new1, new2) = ends(e)
       if weight(e) > 0.0
            println("Checking Ineg T for ")
            show(e)
            for new3 in nodes(g)
            if !isnothing(get_edge(g, new1, new3)) && !isnothing(get_edge(g, new2, new3))
                if  weight(e) <= weight(get_edge(g, new1, new3))+weight(get_edge(g, new2, new3))
                   push!(resultats, true) 
                else 
                   push!(resultats, false)
                   return false
                end
            end
            end
        end
   end
   return all(resultats)
end

function parcours_preordre!(t::Graph{T}, root::Node{T}) where T
    tree_structure = Tree{T}(root,  Vector{Tree{T}}(), missing)
    create_child!(t, tree_structure, [root])

    tour_nodes = Vector{Node{T}}()
    parcours_preordre!(tree_structure, tour_nodes)
    return tour_nodes
end


function parcours_postordre!(t::Graph{T}, root::Node{T}) where T
    tree_structure = Tree{T}(root,  Vector{Tree{T}}(), missing)
    create_child!(t, tree_structure, [root])

    tour_nodes = Vector{Node{T}}()
    parcours_postordre!(tree_structure, tour_nodes)
    return tour_nodes
end