### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ bc2b7bb4-8911-4c02-b81d-06a62ddce517
using Test

# ╔═╡ 116ec11c-2622-44ea-952e-b6bd786010b4
include("../phase 1/graph.jl");

# ╔═╡ 46612913-7022-4537-a927-9fa860c8d156
md"""
# Rapport phase 2
## Corrections et ameliorations apportees a la phase 1
"""

# ╔═╡ 86b0f8de-f0d6-44db-a3b7-4229610fc181
md"""
Suites aux corrections recues, nous avons implemente les changements suivants au fichier ../phase 1/graph.jl:
- get_node envoi un warning et nothing si un noeud n'est pas dans le graphe
- La mise en page de la documentation a ete corrigee
- La fonction build_graph est maintenant dans le fichier graph.jl

De plus, nous avons ameliorer, dans la fonction build_graph, la recuperation du nom du graphe. Ce n'est plus le nom du fichier avec son chemin et son extension, mais simplement le nom qui est donne au graphe.
"""

# ╔═╡ 54b1a094-56b7-49a4-834d-2a01c8c2eb27


# ╔═╡ b010ff64-64c9-47e9-8813-7878df83f80e
md"""
## Composantes connexes
### Une nouvelle structure
"""

# ╔═╡ b06cc8cf-e40c-45d1-942b-8e645b4d099c
"""Type abstrait de composantes connexes"""
abstract type AbstractConComp{T} end

# ╔═╡ 33bcde19-fe4d-46de-84db-8d530ebb7085
"""Type représentant une composante connexe comme un noeud et sa racine.
"""
mutable struct Component{T} <: AbstractConComp{T}
  node::Node{T}
  root::Node{T}
end

# ╔═╡ 484ce341-47b1-4dfd-89a7-ca373ef77f3b
md"""
La strategie est donc de représenter un arbre couvrant d'un graphe G comme un vecteur de composantes connexes: une par noeuds de G. On a donc besoin de plusieurs fonctions sur les composantes connexes, que nous détaillons dans la partie suivante.
### Des fonctions pour modifier les composantes connexes et vecteurs de composantes connexes
"""

# ╔═╡ ae6b414f-3a44-49d0-a614-f9aea2d9150a
"""
Prend en parametre une composante connexe et un noeud n. Renvoi la composante connexe en ayant changé sa racine pour le noeud n.
"""
function set_root!(comp::Component{T}, n::Node{T}) where T
    comp.root = n
    comp
end

# ╔═╡ 00b6844d-415b-486a-a043-28bf6a1eea44
"""
Renvoi le vecteur de composantes connexes decrivant un arbre couvrant auquel on a ajouté la composante connexe new avec pour racine la composante connexe root
"""
function add!(comp::Vector{Component{T}}, root::Component{T}, new::Component{T}) where T
    push!(comp, new)
    new.root= node(root)
    comp
end

# ╔═╡ 8ccb4364-3931-46b6-879e-489ddd8fb621
"""
Renvoi le vecteur de composantes connexes auquel on a ajouté la composante connexe new 
"""
function add!(comp::Vector{Component{T}}, new::Component{T}) where T
    push!(comp, new)
    comp
end


# ╔═╡ 08aae609-c074-4920-b62a-d02e329e7147
md"""### Des fonctions utilitaires"""

# ╔═╡ 78a25619-8154-49b8-b096-efea95ecd99c
"""
Prend en parametre un graphe g et son vecteur de composantes connexes associé.

Construit le graphe correspondant au sous graphe de g décrit par le vecteur de composantes connexes

"""
function to_graph(comp::Vector{Component{T}}, g::Graph{T}) where T
    tree = Graph{T}("covering tree (kruskal) of $(name(g))", copy.(nodes(g)), Vector{Edge{T}}())
    for i in 1:nb_nodes(tree)
         current=comp[i]
        if name(root(current)) != name(node(current))
            e = get_edge(g, root(current), node(current))
            push!(edges(tree), Edge{T}((root(current), node(current)), weight(e)))
        end
    end
    return tree
end

# ╔═╡ ecab857c-37b1-48b3-b815-3fc5a55bc55e
"""Renvoi le vecteur des composantes connexes associees a un graphe. Il y en a autant que de nodes dans le graphe"""
function to_components(graph::Graph{T}) where T
    comp = Vector{Component{T}}()
    for n in nodes(graph)
        push!(comp, to_component(n))
    end
    return comp
end


# ╔═╡ 9184c85d-d3ed-4272-97fd-02bad3d58fc7
""" 
Renvoi l'element du vecteur comp tel que s est le nom du noeud de l'element.
"""
function get_component(comp::Vector{Component{T}}, s::String) where T
    i = findfirst(x -> ( name(node(x)) == s), comp)  
    if isnothing(i)
        return i 
    end
    return comp[i]
end

# ╔═╡ 5f8a9696-ab98-4bd4-9173-9459cb2d4f36
"""
Renvoi la racine de l'arbre auquel appartient new 
"""
function trace_back(comp::Vector{Component{T}}, new::Component{T}) where T
    current = new
    while name(root(current)) != name(node(current))
        current = get_component(comp, name(root(current)))
    end
    return current
end


# ╔═╡ b6904d0e-194f-4167-9a0a-b1acaed916cd
""" 
Renvoi l'index de l'element du vecteur comp tel que s est le nom du noeud de l'element.
"""
function get_component_index(comp::Vector{Component{T}}, s::String) where T
    return findfirst(x -> ( name(node(x)) == s), comp)  
end


# ╔═╡ d2113539-e8cd-484c-9ac6-b23d1621e97f
"""
Renvoi true si une composante c est sa propre racine, false sinon
"""
function is_lonely(c::AbstractConComp)
    return name(node(c)) == name(root(c))
end

# ╔═╡ b949b11d-704e-4d8a-ba73-0903750c8763
md""" 
## Algorithme de Kruskal
"""

# ╔═╡ 93915d9e-a3c5-450e-a451-653d90974228
"""
Prend en parametre un graphe
    - Construit un vecteur de composantes connexes telles que chaque element est un noeud du graphe avec elle meme pour racine
    - Applique l'algorithme de kruskal au graphe et en garde la progression dans le vecteur de composantes connexes
    - retourne un objet graphe correspondant a l'arbre couvrant minimal obtenu.
"""
function kruskal(g::Graph{T}) where T
	
	#Construit un vecteur de composantes connexes telles que chaque element est un noeud du graphe avec elle meme pour racine
    comp = to_components(g)

	#Tri les aretes de g par poids croissant
    edge_sorted = sort(edges(g), by=weight)
	
	for e in edge_sorted
		#Recuperes la composante de chaque extremite de l'arete e
    	new1 = get_component(comp, name(ends(e)[1]))
    	new2 = get_component(comp, name(ends(e)[2]))

    	#Si new1 et new2 ne font pas parti de la meme composante connexe
    	if name_og_root(comp, new1) != name_og_root(comp, new2)
			
        	#Si new1 est sa propre racine
        	if is_lonely(new1)
            	set_root!(new1, node(new2))
				
        	#Sinon Si new2 est sa propre racine
        	elseif is_lonely(new2)
            	set_root!(new2, node(new1))
        	end
			
    	end
	end
	#Renvoi le graphe construit a partir du vecteur de composantes connexes
	return to_graph(comp, g)
end

# ╔═╡ c6e9ec94-f94a-4820-a109-0c74f18e73eb
md"""
## Tests unitaires

Des tests unitaires on été implémentés, en prenant en compte un l'exemple ainsi que des cas limites.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
"""

# ╔═╡ Cell order:
# ╟─bc2b7bb4-8911-4c02-b81d-06a62ddce517
# ╟─116ec11c-2622-44ea-952e-b6bd786010b4
# ╟─46612913-7022-4537-a927-9fa860c8d156
# ╟─86b0f8de-f0d6-44db-a3b7-4229610fc181
# ╟─54b1a094-56b7-49a4-834d-2a01c8c2eb27
# ╟─b010ff64-64c9-47e9-8813-7878df83f80e
# ╟─b06cc8cf-e40c-45d1-942b-8e645b4d099c
# ╟─33bcde19-fe4d-46de-84db-8d530ebb7085
# ╟─484ce341-47b1-4dfd-89a7-ca373ef77f3b
# ╟─ae6b414f-3a44-49d0-a614-f9aea2d9150a
# ╟─00b6844d-415b-486a-a043-28bf6a1eea44
# ╟─8ccb4364-3931-46b6-879e-489ddd8fb621
# ╟─08aae609-c074-4920-b62a-d02e329e7147
# ╟─5f8a9696-ab98-4bd4-9173-9459cb2d4f36
# ╟─78a25619-8154-49b8-b096-efea95ecd99c
# ╟─ecab857c-37b1-48b3-b815-3fc5a55bc55e
# ╟─9184c85d-d3ed-4272-97fd-02bad3d58fc7
# ╟─b6904d0e-194f-4167-9a0a-b1acaed916cd
# ╟─d2113539-e8cd-484c-9ac6-b23d1621e97f
# ╟─b949b11d-704e-4d8a-ba73-0903750c8763
# ╠═93915d9e-a3c5-450e-a451-653d90974228
# ╟─c6e9ec94-f94a-4820-a109-0c74f18e73eb
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
