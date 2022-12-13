# import Base.show
# using Test
# include("../phase 1/graph.jl")

# """Type abstrait de composantes connexes"""
# abstract type AbstractConComp{T} end

# """Type représentant une composante connexe comme un noeud et sa racine.
# """
# mutable struct Component{T} <: AbstractConComp{T}
#   node::Node{T}
#   root::Node{T}
# end

# """
# Renvoi le noeud correspondant a la composante connexe.
# """
# node(comp::AbstractConComp) = comp.node

# """
# Renvoi le noeud correspondant a la racine du noeud de la composante connexe.
# """
# root(comp::Component{T}) where T= comp.root

# """
# Prend en parametre une composante connexe et un noeud n. Renvoi la composante connexe en ayant changé sa racine pour le noeud n.
# """
# function set_root!(comp::Component{T}, n::Node{T}) where T
#     comp.root = n
#     comp
# end

# """
# Renvoi la composante correspondant a la racine de l'arbre auquel appartient new 
# """
# function trace_back(comp::Vector{Component{T}}, new::Component{T}) where T
#     current = new
#     while name(root(current)) != name(node(current))
#         current = get_component(comp, name(root(current)))
#     end
#     return current
# end

# """
# Prend un vecteur de composantes connexes et renvoi le nom de la racine de la composante contenant new 
# """
# function name_og_root(comp::Vector{Component{T}}, new::Component{T}) where T
#     n = name(node(trace_back(comp, new))) 
#     return n
# end

# """
# Renvoi le vecteur de composantes connexes decrivant un arbre couvrant auquel on a ajouté la composante connexe new avec pour racine la composante connexe root
# """
# function add!(comp::Vector{Component{T}}, root::Component{T}, new::Component{T}) where T
#     push!(comp, new)
#     new.root= node(root)
#     comp
# end

# """
# Renvoi le vecteur de composantes connexes auquel on a ajouté la composante connexe new 
# """
# function add!(comp::Vector{Component{T}}, new::Component{T}) where T
#     push!(comp, new)
#     comp
# end

# """Renvoi le vecteur des composantes connexes associees a un graphe. Il y en a autant que de nodes dans le graphe"""
# function to_con_components(graph::Graph{T}) where T
#     comp = Vector{Component{T}}()
#     for n in nodes(graph)
#         push!(comp, to_component(n))
#     end
#     return comp
# end

# """
# Renvoi une composante connexe singloton correspondante au noeud n
# """
# function to_component(n::Node{T}) where T
#     return Component(n,n)
# end

# """ 
# Renvoi l'element du vecteur comp tel que s est le nom du noeud de la composante.
# """
# function get_component(comp::Vector{Component{T}}, s::String) where T
#     i = findfirst(x -> ( name(node(x)) == s), comp)  
#     if isnothing(i)
#         return i 
#     end
#     return comp[i]
# end

# """ 
# Renvoi l'index de l'element du vecteur comp tel que s est le nom du noeud de la composante.
# """
# function get_component_index(comp::Vector{Component{T}}, s::String) where T
#     return findfirst(x -> ( name(node(x)) == s), comp)  
# end

# """
# Prend en parametre un graphe g et son vecteur de composantes connexes associé.
# Construit le graphe correspondant au sous graphe de g décrit par le vecteur de composantes connexes

# """
# function to_graph(comp::Vector{Component{T}}, g::Graph{T}) where T

#     tree = Graph{T}("covering tree (kruskal) of $(name(g))", copy.(nodes(g)), Vector{Edge{T}}())
#     for i in 1:nb_nodes(tree)
#         current=comp[i]
#         if name(root(current)) != name(node(current))
#             e = get_edge(g, root(current), node(current))
#             push!(edges(tree), Edge{T}((root(current), node(current)), weight(e)))
#         end
#     end
#     return tree
# end

# """
# Renvoi true si c est sa propre racine, false sinon
# """
# function is_lonely(c::AbstractConComp)
#     return name(node(c)) == name(root(c))
# end

# """
# Prend en parametre un graphe
#     - Construit un vecteur de composantes connexes telles que chaque element est un noeud du graphe avec elle meme pour racine
#     - Applique l'algorithme de kruskal au graphe et en garde la progression dans le vecteur de composantes connexes
#     - retourne un objet graphe correspondant a l'arbre couvrant minimal obtenu.
# """
# function kruskal(g::Graph{T}) where T
	
# 	#Construit un vecteur de composantes connexes telles que chaque element est un noeud du graphe avec elle meme pour racine
#     comp = to_con_components(g)

# 	#Tri les aretes de g par poids croissant
#     edge_sorted = sort(edges(g), by=weight)
	
# 	for e in edge_sorted
# 		#Recuperes la composante de chaque extremite de l'arete e
#     	new1 = get_component(comp, name(ends(e)[1]))
#     	new2 = get_component(comp, name(ends(e)[2]))

#     	#Si new1 et new2 ne font pas parti de la meme composante connexe
#     	if name_og_root(comp, new1) != name_og_root(comp, new2)
			
#         	#Si new1 est sa propre racine
#         	if is_lonely(new1)
#             	set_root!(new1, node(new2))
				
#         	#Sinon Si new2 est sa propre racine
#         	elseif is_lonely(new2)
#             	set_root!(new2, node(new1))
#         	end
			
#     	end
# 	end
# 	#Renvoi le graphe construit a partir du vecteur de composantes connexes
# 	return to_graph(comp, g)
# end
