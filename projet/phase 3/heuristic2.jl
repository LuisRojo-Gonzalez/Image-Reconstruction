include("./new_connex.jl")



"""Type représentant une composante connexe comme un vecteur de noeuds, un entier (le rang de la racine) et la racine de cette composante (un noeud)
"""
mutable struct Component_root{T} <: AbstractComp{T}
  nodes::Vector{Node{T}}
  rang::Int
  root::Node{T}
end
rang(c::AbstractComp) = c.rang
root(c::AbstractComp) = c.root
function set_rang!(c::AbstractComp, r::Int)
    c.rang = r
    c
end

function get_component_with_node(tree::Vector{Component_root{T}}, n::Node{T}) where T
    for c in tree
        i = findfirst(x -> name(x) == name(n), nodes(c))
        if !isnothing(i)
            return c
        end
    end
    return nothing
end

function empty!(comp::Component_root{T}) where T
    comp.nodes = Vector{Node{T}}()
    comp
end


"""
Prend en argument un graphe et renvoi le vecteur de ses composantes connexes triviales
"""
function to_components_root(g::Graph{T}) where T
    tmp = Vector{Component_root{T}}()
    for n in nodes(g)
        d= [n]
        solo = Component_root{T}(d,0, n)
        push!(tmp, solo)
    end
    return tmp
end

"""
Ajoute les noeuds de la composante comp2 a la composante comp1
"""
function add_nodes!(comp1::Component_root{T}, comp2::Component_root{T}) where T
    for k in nodes(comp2)
        push!(nodes(comp1), k)
    end
    comp1
end


""" renvoi si les deux composantes ont la meme racine (et donc sont identiques) ou non"""
function same_root(comp1::Component_root{T}, comp2::Component_root{T}) where T
    return name(root(comp1)) == name(root(comp2))
end


"""
Prend en parametre un graphe et renvoi un graphe qui en est un arbre couvrant a cout minimum en utilisant l'algorithme de Kruskal muni de l'heuristique 2 (compression des chemins)
"""
function kruskal_heur2(g::Graph{T}) where T
	#Tri les aretes de g par poids croissant
    edge_sorted = sort(edges(g), by=weight)
	tree_comps = to_components_root(g)
    #garde en memoire les aretes selectionnees pour l'arbre
    edges_selected = Vector{Edge{T}}()
	for e in edge_sorted
        (new1, new2) = (get_node(g, name(ends(e)[1])), get_node(g, name(ends(e)[2])))
        comp1 = get_component_with_node(tree_comps, new1)
        comp2 = get_component_with_node(tree_comps, new2)
        if !same_root(comp1, comp2)
            push!(edges_selected, e)
            if rang(comp1) > rang(comp2)
                #### ajoute new 2 a la composante de new 1
                add_nodes!(comp1, comp2)
                
                ### on enleve new 2 de sa composante
                empty!(comp2)
            else
                add_nodes!(comp2, comp1)
                empty!(comp1)
                if rang(comp1) == rang(comp2)
                    set_rang!(comp2, rang(comp2) +1)
                end
            end
        end
    end

    return Graph{T}("Heuristique 2 kruskal de $(name(g))", nodes(g), edges_selected)
end