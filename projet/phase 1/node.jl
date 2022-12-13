import Base.show
import Base.copy

"""Type abstrait dont d'autres types de noeuds dériveront."""
abstract type AbstractNode{T} end

"""Type représentant les noeuds d'un graphe.

Exemple:

        noeud = Node("James", [π, exp(1)])
        noeud = Node("Kirk", "guitar")
        noeud = Node("Lars", 2)

"""
mutable struct Node{T} <: AbstractNode{T}
  name::String
  data::T
end


mutable struct Node_d{T} <: AbstractNode{T}
  name::String
  data::T
  degree::Int
end

# on présume que tous les noeuds dérivant d'AbstractNode
# posséderont des champs `name` et `data`.

"""Renvoie le nom du noeud."""
name(node::AbstractNode) = node.name

"""Renvoie les données contenues dans le noeud."""
data(node::AbstractNode) = node.data

"""Affiche un noeud."""
function show(node::AbstractNode)
  #Ajout d'un operateur ternaire dans le cas ou le type de données soit Nothing
  println("Node ", name(node), isnothing(data(node)) ? " " : " data: $(data(node))")
end

""" copy un noeud """
Base.copy(n::AbstractNode) = Node(n.name, n.data)


