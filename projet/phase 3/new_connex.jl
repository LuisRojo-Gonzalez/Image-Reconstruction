import Base.show
using Test
include("../phase 1/graph.jl")

"""Type abstrait de composantes connexes"""
abstract type AbstractComp{T} end

"""Type composante connexe: un dictionnaire ou chaque clef est un noeud, et chaque valeur son parent"""
mutable struct Component{T} <: AbstractComp{T}
    nodes::Dict{Node{T}, Node{T}}
end

nodes(c::AbstractComp) = c.nodes 

"""
Prend en argument un graphe et renvoi un vecteur de composantes connexes initiales (noeud n => noeud n)
"""
function to_components(g::Graph{T}) where T
    tmp = Vector{Component{T}}()
    for n in nodes(g)
        d= Dict{Node{T}, Node{T}}()
        d[n] = n
        solo = Component{T}(d)
        push!(tmp, solo)
    end
    return tmp
end

"""
Vide une composante connexe de ces noeuds
"""
function empty!(comp::AbstractComp{T}) where T
    comp.nodes = Dict{Node{T}, Node{T}}()
    comp
end

"""
Renvoi la composante connexe qui contient le noeud n
"""
function get_component_with_node(tree::Vector{Component{T}}, n::Node{T}) where T
    for c in tree
        if haskey(nodes(c), n)
            return c
        end
    end
    return nothing
end

""" 
Joins la composante connexe comp2 a la composante connexe comp1 en les liant au niveau de l'arete e
"""
function add_nodes_at!(comp1::AbstractComp{T}, comp2::AbstractComp{T}, e::AbstractEdge{T}) where T
    new1, new2 = ends(e)
    if haskey(nodes(comp1),new1)
        nodes(comp1)[new1] = new2
    elseif haskey(nodes(comp1),new2)
        nodes(comp1)[new2] = new1
    end
    for (k,v) in nodes(comp2)
        nodes(comp1)[k] = v
    end
    comp1
end

"""
Renvoi true si les deux composantes connexes sont les memes
"""
function same_component(comp1::AbstractComp, comp2::AbstractComp)
    if length(nodes(comp1)) != length(nodes(comp2))
        return false
    else
        for n in keys(nodes(comp1))
            if !haskey(nodes(comp2), n)
                return false
            end
        end
    end
    return true
end

"""
Prend en parametre un graphe et renvoi un arbre couvrant de poids minimum en utilisant l'algorithme de Kruskal
"""
function kruskal(g::Graph{T}) where T
#Tri les aretes de g par poids croissant
edge_sorted = sort(edges(g), by=weight)
tree_comps = to_components(g)
#garde en memoire les aretes selectionnees pour l'arbre
edges_selected = Vector{Edge{T}}()
for e in edge_sorted
    (new1, new2) = ends(e)
    comp1 = get_component_with_node(tree_comps, new1)
    comp2 = get_component_with_node(tree_comps, new2)
    if !same_component(comp1, comp2)
        push!(edges_selected, e)
        add_nodes_at!(comp1, comp2, e)
        #empty!(comp2)
    end
end
return Graph{T}("Kruskal de $(name(g))", nodes(g), edges_selected)
end

