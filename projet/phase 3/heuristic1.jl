include("./new_connex.jl")


"""Type représentant une composante connexe comme un dictionnaire de clef un noeud et de valeur un noeud (son parent) et un entier (le rang de la racine de cette composante)
"""
mutable struct Component_rg{T} <: AbstractComp{T}
  nodes::Dict{Node{T}, Node{T}}
  rang::Int
end
rang(c::AbstractComp) = c.rang


function set_rang!(c::AbstractComp, r::Int)
    c.rang = r
    c
end

"""
Renvoi la composante contenant le noeud n
"""
function get_component_with_node(tree::Vector{Component_rg{T}}, n::Node{T}) where T
    for c in tree
        if haskey(nodes(c), n)
            return c
        end
    end
    return nothing
end

"""
Prend en argument un graphe et renvoi le vecteur de ses composantes connexes triviales
"""
function to_components_rg(g::Graph{T}) where T
    tmp = Vector{Component_rg{T}}()
    for n in nodes(g)
        d= Dict{Node{T}, Node{T}}()
        d[n] = n
        solo = Component_rg{T}(d, 0)
        push!(tmp, solo)
    end
    return tmp
end

"""
Renvoi la composante connexe contenant le noeud n
"""
function get_component_with_node_rg(tree::Vector{Component_rg{T}}, n::Node{T}) where T
    for c in tree
        if haskey(c, n)
            return true
        end
    end
    return false
end




"""
Prend en parametre un graphe et renvoi un graphe qui en est un arbre couvrant a cout minimum en utilisant l'algorithme de Kruskal muni de l'heuristique du rang
"""
function kruskal_heur1(g::Graph{T}) where T
	#Tri les aretes de g par poids croissant
    edge_sorted = sort(edges(g), by=weight)
	tree_comps = to_components_rg(g)
    #garde en memoire les aretes selectionnees pour l'arbre
    edges_selected = Vector{Edge{T}}()
	for e in edge_sorted
        (new1, new2) = (get_node(g, name(ends(e)[1])), get_node(g, name(ends(e)[2])))
        comp1 = get_component_with_node(tree_comps, new1)
        comp2 = get_component_with_node(tree_comps, new2)
        if !same_component(comp1, comp2)
            push!(edges_selected, e)
            if rang(comp1) > rang(comp2)
                #### ajoute new 2 a la composante de new 1
                add_nodes_at!(comp1, comp2, e)
                
                ### on enleve new 2 de sa composante
                empty!(comp2)
            else
                add_nodes_at!(comp2, comp1, e)
                empty!(comp1)
                if rang(comp1) == rang(comp2)
                    set_rang!(comp2, rang(comp2) +1)
                end
            end
        end
    end

    return Graph{T}("Heuristique 1 kruskal de $(name(g))", nodes(g), edges_selected)
end