# include("../phase 1/graph.jl")
"""Type abstrait de composantes connexes"""
abstract type AbstractComp{T} end

"""Type composante connexe: Deux dictionnaires pour representer un arbre
    - links represente les arcs de l'arbre. Chaque clef est un noeud, et chaque valeur son parent.
    - degrees represente les degres de chaque sommet. (K => V) = noeud => degre 
"""
mutable struct Component{T} <: AbstractComp{T}
    links::Dict{String, String}
    degrees::Dict{String, Int}
end

"""
Getter for the links dictionnary of a component c
"""
links(c::AbstractComp) = c.links

"""
Getter for the degrees dictionnary of a component c
"""
degrees(c::AbstractComp) = c.degrees


"""
Constructor for an elementary Component
"""
function Component{T}() where T
    links = Dict{String, String}()
    degrees = Dict{String, Int}()
    return Component{T}(links, degrees)
end


"""
Vide une composante connexe de tous ses noeuds
"""
function empty!(comp::AbstractComp{T}) where T
    delete!(links(comp), keys(links(comp)))
    delete!(degrees(comp), keys(degrees(comp)))
    comp
end


"""
Gives back the degree of a node n in componant c
"""
function degree(c::AbstractComp, n::Node{T}) where T
    return degrees(c)[name(n)]
end

"""
Met a jour le degre d'un noeud dans un arbre en construction. Si le noeud n'appartient pas a la composante, ajoute le noeud
"""
function set_degree!(c::AbstractComp{T}, n::Node{T}, new_degree::Int64) where T
    degrees(c)[name(n)] = new_degree
    c
end

"""
Incremente de 1 le degre d'un noeud dans un arbre en construction. Si le noeud n'appartient pas a la composante, ne fait rien 
"""
function increase_degree!(c::AbstractComp{T}, n::Node{T}) where T
    if haskey(degrees(c), name(n))
        degrees(c)[name(n)] = degrees(c)[name(n)] + 1
    end
    c
end

"""
Compare deux composantes connexes
"""
function isequal(c1::AbstractComp, c2::AbstractComp)
    return isequal(links(c1), links(c2)) && isequal(degrees(c1), degrees(c2))
end

"""
Ajoute une relation parent-enfant a une composante connexe, ie., mets a jour les degres 
"""
function add_to_comp!(c::AbstractComp{T}, child::Node{T}, parent::Node{T}, deg::Int) where T
    links(c)[name(child)] = name(parent)
    if !haskey(degrees(c), name(child))
        degrees(c)[name(child)] = deg
        if deg > 0
            increase_degree!(c, parent)
        end
    end
    c
end

"""
Prend en argument un graphe et renvoi un vecteur de composantes connexes initiales (noeud n => noeud n, noeud n => 0)
"""
function to_components(g::Graph{T}) where T
    tmp = Vector{Component{T}}()
    for n in nodes(g)
        l = Dict{String, String}()
        d = Dict{String, Int}()
        l[name(n)] = name(n)
        d[name(n)] = 0
        solo = Component{T}(l, d)
        push!(tmp, solo)
    end
    return tmp
end


"""
Renvoi la composante connexe qui contient le noeud n
"""
function get_component_with_node(tree::Vector{Component{T}}, n::Node{T}) where T
    for c in tree
        if haskey(links(c), name(n))
            return c
        end
    end
    return nothing
end

"""
Supprime un noeud d'une composante connexe
"""
function remove_from_comp!(c::AbstractComp{T}, n::Node{T}) where T
    delete!(links(c), n)
    delete!(degrees(c), n)
    c
end

"""
Merge deux composantes connexes
"""
function merge_comp!(comp1::AbstractComp, comp2::AbstractComp)
    comp1.links = Dict(links(comp1)..., links(comp2)...)
    comp1.degrees = Dict(degrees(comp1)..., degrees(comp2)...)
    comp1
end

""" 
Joins la composante connexe comp2 a la composante connexe comp1 en les liant au niveau de l'arete e, et met les degrees a jour
"""
function add_nodes_at!(comp1::AbstractComp{T}, comp2::AbstractComp{T}, e::AbstractEdge{T}) where T
    new1, new2 = ends(e)
    if haskey(links(comp1),name(new1))
        # add starting node to the component
        links(comp1)[name(new2)] = name(new1)
        ##################################################################
        # increases the degree for the nodes adjacents to the new edge e #
        ##################################################################   
        increase_degree!(comp1, new1)
        set_degree!(comp1, new2, degree(comp2, new2)+1) 
        remove_from_comp!(comp2, new2)
    elseif haskey(links(comp1),name(new2))
        # add destination node to the component
        links(comp1)[name(new1)] = name(new2) 
        ##################################################################
        # increases the degree for the nodes adjacents to the new edge e #
        ##################################################################
        set_degree!(comp1, new1, degree(comp2, new1)+1)
        increase_degree!(comp1, new2) 
        remove_from_comp!(comp2, new1)
    end
    merge_comp!(comp1, comp2)
    comp1
end

function parcours_cycle(comp::AbstractComp, start_node::AbstractNode)
    parcours = Vector{Int}()
    lin = links(comp1)
    current = start_node
    
    while haskey(lin, name(current))
        next = lin[name(current)]
        push!(parcours,parse(Int, name(current)))
        current = next
    end
    return parcours
end

function parcours_cycle(g::Graph)
    parcours = Vector{Int}()
    prev = get_node(g, "1")
    current = get_node(g, "1")
    next = get_all_neighbours(g, get_node(g, "1"))[1]
    while name(next) != "1"
        push!(parcours, parse(Int, name(next)))
        prev = current
        current = next
        tmp = get_all_neighbours(g, current)
        @show tmp
        if name(tmp[1]) == name(prev)
            next = tmp[2]
        else
            next = tmp[1]
        end
    end
    @show parcours
    return parcours
end