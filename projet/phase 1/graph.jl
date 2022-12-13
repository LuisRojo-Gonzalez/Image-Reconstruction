
import Base.show
import Base.copy
include("edge.jl")


"""Type abstrait dont d'autres types de graphes dériveront."""
abstract type AbstractGraph{T} end

"""Type representant un graphe comme un ensemble de noeuds.

Exemple :

    node1 = Node("Joe", 3.14)
    node2 = Node("Steve", exp(1))
    node3 = Node("Jill", 4.12)
    G = Graph("Ick", [node1, node2, node3])

Attention, tous les noeuds doivent avoir des données de même type.
"""
mutable struct Graph{T} <: AbstractGraph{T}
  name::String
  nodes::Vector{Node{T}}
  #nodes::Vector{AbstractNode{T}}
  edges::Vector{Edge{T}}
  #edges::Vector{AbstractEdge{T}}
end

function Graph()
  name = ""
  nodes = Vector{Node{Nothing}}()
  edges = Vector{Edge{Nothing}}()
  return Graph(name, nodes, edges)
end

"""Ajoute un noeud au graphe."""
function add_node!(graph::Graph{T}, node::Node{T}) where T
  push!(graph.nodes, node)
  graph
end
function add_edge!(graph::Graph{T}, edge::Edge{T}) where T
  push!(graph.edges, edge)
  graph
end
# on présume que tous les graphes dérivant d'AbstractGraph
# posséderont des champs `name` et `nodes`.

"""Renvoie le nom du graphe."""
name(graph::AbstractGraph) = graph.name

"""Renvoie la liste des noeuds du graphe."""
nodes(graph::AbstractGraph) = graph.nodes


"""Renvoie le nombre de noeuds du graphe."""
nb_nodes(graph::AbstractGraph) = length(graph.nodes)

"""Renvoie la liste des edges du graphe."""
edges(graph::AbstractGraph) = graph.edges

"""Renvoie le nombre des edges du graphe."""
nb_edges(graph::AbstractGraph) = length(graph.edges)

function test_graph()

  g = Graph{Char}("", Vector{Node{Char}}(),Vector{Edge{Char}}())
  for i in 1:9
    n = Node(string('a' + i-1), 'a' + i-1)
    add_node!(g, n)
  end
  add_edge!(g, Edge((get_node(g, "a"), get_node(g, "b")), 4.0))
  add_edge!(g, Edge( (get_node(g, "a"), get_node(g, "h")), 8.0))
  add_edge!(g, Edge((get_node(g, "b"), get_node(g, "h")), 11.0))
  add_edge!(g, Edge((get_node(g, "b"), get_node(g, "c")), 8.0))
  add_edge!(g, Edge((get_node(g, "h"), get_node(g, "i")), 7.0))
  add_edge!(g, Edge((get_node(g, "g"), get_node(g, "h")), 1.0))
  add_edge!(g, Edge((get_node(g, "i"), get_node(g, "g")), 6.0))
  add_edge!(g, Edge((get_node(g, "i"), get_node(g, "c")), 2.0))
  add_edge!(g, Edge((get_node(g, "g"), get_node(g, "f")), 2.0))
  add_edge!(g, Edge((get_node(g, "c"), get_node(g, "f")), 4.0))
  add_edge!(g, Edge((get_node(g, "c"), get_node(g, "d")), 7.0))
  add_edge!(g, Edge((get_node(g, "d"), get_node(g, "f")), 14.0))
  add_edge!(g, Edge((get_node(g, "d"), get_node(g, "e")), 9.0))
  add_edge!(g, Edge((get_node(g, "f"), get_node(g, "e")), 10.0))
  return g
end

function test_graph_complet()
  root = Node("s", 0)
  g = Graph{Int}("", Vector{Node{Int}}(),Vector{Edge{Int}}())
  add_node!(g, root)
  for i in 1:9
    n = Node(string(i), i)
    add_node!(g, n)
  end
  for i in 1:9
    add_edge!(g, Edge((get_node(g, "$i"), root), 0.0))
    for j in (i+1):9
      add_edge!(g, Edge((get_node(g, "$i"), get_node(g, "$j")), rand(0:3) * 1.0))
    end
  end
  return g
end


"""Retourn l'indice dans le vecteur des noeuds du graphe graph du noeud s. Nothing si le noeud ne fait pas parti du graphe."""
function get_node(graph::Graph, s::String) 
  i = findfirst(x -> ( name(x) == s), nodes(graph))  

  if !(isnothing(i)) 
    return nodes(graph)[i] 
  else
    @warn("Graph $(name(graph)) has no node $s")
  end
  return nothing
end

"""Affiche un graphe"""
function show(graph::Graph)
  println("Graph ", name(graph), " has ", nb_nodes(graph), " nodes and $(nb_edges(graph)) edges.")
  for node in nodes(graph)
    show(node)
  end
  for edge in edges(graph)
    show(edge)
  end
end


""" Renvoi un objet edge du graphe g avec pour extremites n1 et n2. nothing sinon"""
function get_edge(g::Graph{T}, n1::Node{T}, n2::Node{T}) where T
    i = findfirst(x ->name.(ends(x)) == (name(n1), name(n2)) , edges(g))
    if isnothing(i)
      i = findfirst(x -> name.(ends(x)) == (name(n2), name(n1)) , edges(g))
      if isnothing(i) 
        return nothing
      end
    end

  return edges(g)[i]
end



function get_edge_index_in_list(vec::Vector{Edge{T}}, n1::Node{T}, n2::Node{T}) where T
  i = findfirst(x ->name.(ends(x)) == (name(n1), name(n2)) ,vec)
  if isnothing(i)
    i = findfirst(x -> name.(ends(x)) == (name(n2), name(n1)) , vec)
    if isnothing(i) 
      return 0
    end
  end

return i
end


function get_edge_in_list(vec::Vector{Edge{T}}, n1::Node{T}, n2::Node{T}) where T
  i = findfirst(x ->name.(ends(x)) == (name(n1), name(n2)) ,vec)
  if isnothing(i)
    i = findfirst(x -> name.(ends(x)) == (name(n2), name(n1)) , vec)
    if isnothing(i) 
      return nothing
    end
  end

return vec[i]
end


function get_associated_edges(g::AbstractGraph{T}, n::AbstractNode{T}) where T
  e_with_n = Vector{AbstractEdge{T}}()
  for e in edges(g)
    if name(ends(e)[1]) == name(n) || name(ends(e)[2]) == name(n)
      push!(e_with_n, e)
    end
  end
  return e_with_n
end

function copy(g::Graph{T}) where T
  new_edges = deepcopy(edges(g))
  new_nodes = deepcopy(nodes(g))
  new_name = "$(name(g))-copie"
  return Graph{T}(new_name, new_nodes, new_edges)
end

function max_degre(graph::Graph)
  degres = Vector{Int}()
  for n in nodes(graph)
    push!(degres, length(get_associated_edges(graph,n)))
  end
  return findmax(degres)[2]
end

function get_all_neighbours(g::Graph, n::Node)
  ed = get_associated_edges(g, n)
  neigh = Vector{Node}()
  for e in ed
    a,b = ends(e)
    if name(a) == name(n)
      push!(neigh, b)
    else
      push!(neigh, a)
    end
  end
  return neigh
end


function get_weight_of(g::Graph{Int}, tour::Vector{Int})
  total_weight = 0
  for i in 1:length(tour) - 1
    total_weight += weight(get_edge(g, get_node(g, string(tour[i])), get_node(g, string(tour[i+1]))))
  end
  return convert(Float32,total_weight)
end

function get_degree(g::Graph, n::Node)
  return length(get_associated_edges(g, n))
end