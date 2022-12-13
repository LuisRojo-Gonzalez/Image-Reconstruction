import Base.show
import Base.isequal
include("node.jl")

"""Type abstrait dont d'autres types d'aretes dériveront."""
abstract type AbstractEdge{T} end

"""Type représentant les aretes d'un graphe.
"""
mutable struct Edge{T} <: AbstractEdge{T}
  ends::Tuple{Node{T}, Node{T}}
  weight::Float64
end

ends(edge::AbstractEdge) = edge.ends

weight(edge::AbstractEdge) = edge.weight

function set_weight!(edge::AbstractEdge, w::Float64)
  edge.weight = w
  edge
end
function reverse_edge(e::AbstractEdge)
  return Edge((ends(e)[2], ends(e)[1]), weight(e))
end


function show(edge::AbstractEdge)
  println( "Edge:  ($(name(ends(edge)[1])),$(name(ends(edge)[2])))   weight: $(weight(edge))" )
end


function isequal(e1::AbstractEdge, e2::AbstractEdge)
  n11, n12 = ends(e1)
  n21, n22 = ends(e2)
  if name(n11) == name(n21) && name(n12) == name(n22) || name(n11) == name(n22) && name(n21) == name(n12)
    return true 
  end
  return false
end