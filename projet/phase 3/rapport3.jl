### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ 1157d220-592a-11ed-1825-29094a4fcc68
md"""
# Rapport phase 3
## Ameliorations apportees a la phase 2
"""

# ╔═╡ 7ebdf853-823a-4fa7-99f2-acfbba841702
md"""
## Composantes connexes
### Une nouvelle structure
"""

# ╔═╡ ae835729-49f7-4015-ba7d-9ae0f1568c2d
md"""Premiérement nous avons changé le Type composante connexe, le type devient  un dictionnaire ou chaque clef est un noeud, et chaque valeur son parent """

# ╔═╡ 2ce97035-1a35-4c5d-8986-c318411b5f9a
md""" 
```julia
mutable struct Component{T} <: AbstractComp{T}
    nodes::Dict{Node{T}, Node{T}}
end
```
"""
  

# ╔═╡ 58251d14-4133-48e9-825f-fed35ef2b274
md"""
La strategie est donc de représenter un arbre couvrant d'un graphe G comme un vecteur de composantes connexes: une par noeuds de G. On a donc besoin de plusieurs fonctions sur les composantes connexes, que nous détaillons dans la partie suivante.
### Des fonctions pour modifier les composantes connexes et vecteurs de composantes connexes
"""

# ╔═╡ 091f9dc3-fb9b-42a8-9222-9b76f34e4a0d
md"""
Prend en argument un graphe et renvoi un vecteur de composantes connexes initiales (noeud n => noeud n)
"""

# ╔═╡ 86c0daa1-93b7-4a82-8a59-852bf29815ee
md""" 
``` julia
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
``` 
"""

# ╔═╡ 0fb892bb-601f-472a-a799-8594adc121d0
md"""
Vide une composante connexe de ces noeuds
"""

# ╔═╡ 4bebc815-22db-4bb7-8a9e-9ae3f2e4a026
md""" 
``` julia

function empty!(comp::AbstractComp{T}) where T
    comp.nodes = Dict{Node{T}, Node{T}}()
    comp
end
```
"""

# ╔═╡ 6849a51a-8a8c-48dc-a276-33ea2491f512


md"""Renvoi la composante connexe qui contient le noeud n
"""



# ╔═╡ 80e18572-793f-41d6-9649-b715c2529407
md""" 
```julia
function get_component_with_node(tree::Vector{Component{T}}, n::Node{T}) where T
    for c in tree
        if haskey(nodes(c), n)
            return c
        end
    end
    return nothing
end

``` 
"""

# ╔═╡ a714fc49-ee75-44dc-9123-34fc22684685
md""" 
Joins la composante connexe comp2 a la composante connexe comp1 en les liant au niveau de l'arete e
"""

# ╔═╡ c18a2b1f-b53b-4375-8e93-84e637072c99
md""" 
```julia
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
```
"""

# ╔═╡ e0d29977-21b5-46e9-956c-86f6dc4d197f
md"""Renvoi true si les deux composantes connexes sont les memes"""

# ╔═╡ 9856a7ad-0bf6-49bc-8140-c0069fbad015
md""" 
```julia

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


```
"""

# ╔═╡ 9e14296c-89c1-4a0f-aff9-34aec5f040f7
md""" 
## Algorithme de Kruskal
"""

# ╔═╡ 789ee4ba-a0fe-44db-a5a6-fc2dce7a80aa
md"""
Prend en parametre un graphe et renvoi un arbre couvrant de poids minimum en utilisant l'algorithme de Kruskal
"""

# ╔═╡ 05d5b159-9ce6-4b2d-b245-ffdb5e0f3cc4
md"""
```julia
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
        empty!(comp2)
    end
end
return Graph{T}("Kruskal de $(name(g))", nodes(g), edges_selected)
end
```
"""

# ╔═╡ eda7f02a-8300-4fff-8958-2450e2df53f3
 md"""## Implémentation de l'heuristique 1-union via le rang

 """

# ╔═╡ cffc2390-5661-4303-856c-86507354cc7d
md"""
-Prend en parametre un graphe.\
-Renvoi un graphe qui en est un arbre couvrant a cout minimum en utilisant l'algorithme de Kruskal muni de l'heuristique du rang.\
-les modifications sont faites dans la boucle for.
"""

# ╔═╡ 4fb4ac52-3028-46db-8de1-6185b794b168
md"""
```julia
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
```
"""

# ╔═╡ 312dc382-4e66-4ae4-82a5-6e1fe7e114e3
 md"""## Implémentation de l'heuristique 2- compression des chemins """


# ╔═╡ 9a18ce8d-00dd-4b8f-9f18-acf0c6f9d6c0
md""" 
-on a utilisé une fonction renvoi si les deux composantes ont la meme racine (et donc sont identiques) ou non.\
-Prend en parametre un graphe et renvoi un graphe qui en est un arbre couvrant a cout minimum en utilisant l'algorithme de Kruskal muni de l'heuristique 2 (compression des chemins).
--les modifications sont faites dans la boucle for.
"""

# ╔═╡ 205c5fb7-b39f-48c3-884c-ca734bf6b23a
md"""
```julia
function same_root(comp1::Component_root{T}, comp2::Component_root{T}) where T
    return name(root(comp1)) == name(root(comp2))
end
```
"""

# ╔═╡ c688326a-9ffe-47d8-ab59-65e78bb96fdb




md"""
```julia
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
```
"""

# ╔═╡ 317b4f6a-8c87-4e02-a810-a0208b3ffba7
md""" ## Algorithme de Prim """

# ╔═╡ 4e703fcc-25c8-4775-90c3-845196647c6b
md""" Pour l'implémentation de cet algorithme des Fonctions utilitaires sont utilisées"""

# ╔═╡ 32bc9b3b-3630-4114-804c-57ed9031a1d5
md""" Déffinisson une fonction *get_all_edges_with_node qui \
-Prend en argument un graphe et un noeud.\
-Retourne toutes les aretes du graphe incidente au noeud.
"""

# ╔═╡ 0cca8654-3434-42e1-ab86-98021a6a6574

md"""
```julia
function get_all_edges_with_node(g::AbstractGraph, node::AbstractNode)
    edges = Vector{AbstractEdge}()
    for n in nodes(g)
        e = get_edge(g, node, n)
        if !isnothing(e)
            push!(edges,e)
        end
    end
   return edges
end
```
"""

# ╔═╡ db468e7e-0491-4bb2-a14b-18994b361779
md""" Déffinisson une fonction *node_to_add qui \
-Prend en parametre un vecteur des noeuds deja ajoutes a l'arbre de recouvrement et une arete\
-Retourne l'extremité de l'arete qui n'appartient pas encore a l'arbre nothing sinon
"""


# ╔═╡ 1cbf4839-30a1-4046-aa3b-79aa80014159
md"""
```julia
function node_to_add(nodes_added::Vector{Node{T}}, new_edge::Edge{T}) where T
    (n1, n2) = ends(new_edge)
    i1 = findfirst(x -> name(x) == name(n1), nodes_added)
    i2 = findfirst(x -> name(x) == name(n2), nodes_added)
    if (sum(isnothing.([i1, i2])) == 1)
        if isnothing(i1) 
            return n1
        else
            return n2
        end
    end
    return nothing
end
```
"""

# ╔═╡ 3e80feb1-9f31-407a-a4af-a12736622154
md""" ### Algorithme Prim"""

# ╔═╡ 87e773e7-6766-4fa6-bce7-113006850e34
md""" Déffinisson une fonction *prim  qui\
Prend en parametre un grapheet renvoi un graphe qui est un de ses arbres de recouvrement minimum.\
-Une brève documentation est présentée dans la fonction.
"""

# ╔═╡ b5933bdc-1174-44ea-bc18-4d269eb3e3a0
md"""
```julia

function prim(g::Graph{T}) where T
    
    edges_selected = Vector{Edge{T}}()

    #Toutes les aretes sont dans une structure mutable ordonnee. Le poids de l'arete sert d'indice de priorité. Plus l'arete est legere, plus elle est prioritaire
    edges_sorted = MutableBinaryHeap{Edge{T}}(Base.By(weight))
    
    #on choisi au hasard une racine
    current_node = nodes(g)[rand(1:nb_nodes(g))]
    #On garde en memoire les noeuds couverts par l'arbre
    nodes_added =[current_node]

    #boolean qui indique quand il faut ajouter de nouvelles aretes aux aretes candidates
    node_updated = true

    #tant que tous les noeuds n<ont pas ete atteinds
    while length(nodes_added) < nb_nodes(g)

        if node_updated
            #On cherche toutes les aretes incidentes au noeud qu<on vient d'ajouter
            for e in get_all_edges_with_node(g, current_node)
                push!(edges_sorted, e)
             end
        end
        node_updated = false
        #On recupere l'arete la moins chere ATTEIGNABLE
        new_edge = pop!(edges_sorted) 
       
        #On identifi quel noeud est ajouté avec l'ajout de cet arete
        new_node = node_to_add(nodes_added, new_edge)
        if !(isnothing(new_node))
            #On ajoute l'arete a l'arbre
            push!(edges_selected, new_edge)
            #On ajoute le nouveau noeud a notre liste
            push!(nodes_added, new_node)
            current_node = new_node
            node_updated = true
        end   
    end

    return Graph("Prim arbre couvrant min de $(name(g))", nodes(g), edges_selected)
end

```
"""

# ╔═╡ 19f06c41-1dff-4f9a-a4ef-b1304356a960
md"""
## Tests unitaires
Des tests unitaires on été implémentés, en prenant en compte un l'exemple ainsi que des cas limites.
"""

# ╔═╡ 331d5a99-2c8d-411a-a609-6747082b5a59
md"""
## Main
L'execution de la commande 
```shell
julia main.jl $(instance)
```
produit en output le benchmark de chacunes de trois implementations de l'algorithme de Kruskal et de l'algorithme de Prim.
"""

# ╔═╡ 43fc6254-64e4-4db3-93be-c98265ecb791
md"""
Pour toutes les instances symetriques, les resultats sont comparables:
- Les heuristiques de Kruskal permettent de diminuer le temps d'execution. C'est surtout la memoire allouee et le nombre d'allocation qui diminu drastiquement (du simple - kruskal_heur2 - au triple - kruskal -)
- L'algorithme de Prim implemente ainsi semble particulierement moins efficace que l'algorithme de Kruskal; meme sans heuristiques.
"""

# ╔═╡ f0435117-b50d-4bc5-acef-689fae0c3d9e


# ╔═╡ 229e54ce-2f4d-4752-a498-b4fbe1a852fd


# ╔═╡ c94dffe8-40db-4874-aad3-b546cff0b4a6


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"
project_hash = "da39a3ee5e6b4b0d3255bfef95601890afd80709"

[deps]
"""

# ╔═╡ Cell order:
# ╟─1157d220-592a-11ed-1825-29094a4fcc68
# ╟─7ebdf853-823a-4fa7-99f2-acfbba841702
# ╟─ae835729-49f7-4015-ba7d-9ae0f1568c2d
# ╟─2ce97035-1a35-4c5d-8986-c318411b5f9a
# ╟─58251d14-4133-48e9-825f-fed35ef2b274
# ╟─091f9dc3-fb9b-42a8-9222-9b76f34e4a0d
# ╟─86c0daa1-93b7-4a82-8a59-852bf29815ee
# ╟─0fb892bb-601f-472a-a799-8594adc121d0
# ╟─4bebc815-22db-4bb7-8a9e-9ae3f2e4a026
# ╟─6849a51a-8a8c-48dc-a276-33ea2491f512
# ╟─80e18572-793f-41d6-9649-b715c2529407
# ╟─a714fc49-ee75-44dc-9123-34fc22684685
# ╟─c18a2b1f-b53b-4375-8e93-84e637072c99
# ╟─e0d29977-21b5-46e9-956c-86f6dc4d197f
# ╟─9856a7ad-0bf6-49bc-8140-c0069fbad015
# ╟─9e14296c-89c1-4a0f-aff9-34aec5f040f7
# ╟─789ee4ba-a0fe-44db-a5a6-fc2dce7a80aa
# ╟─05d5b159-9ce6-4b2d-b245-ffdb5e0f3cc4
# ╟─eda7f02a-8300-4fff-8958-2450e2df53f3
# ╟─cffc2390-5661-4303-856c-86507354cc7d
# ╟─4fb4ac52-3028-46db-8de1-6185b794b168
# ╟─312dc382-4e66-4ae4-82a5-6e1fe7e114e3
# ╟─9a18ce8d-00dd-4b8f-9f18-acf0c6f9d6c0
# ╟─205c5fb7-b39f-48c3-884c-ca734bf6b23a
# ╟─c688326a-9ffe-47d8-ab59-65e78bb96fdb
# ╠═317b4f6a-8c87-4e02-a810-a0208b3ffba7
# ╟─4e703fcc-25c8-4775-90c3-845196647c6b
# ╟─32bc9b3b-3630-4114-804c-57ed9031a1d5
# ╟─0cca8654-3434-42e1-ab86-98021a6a6574
# ╟─db468e7e-0491-4bb2-a14b-18994b361779
# ╟─1cbf4839-30a1-4046-aa3b-79aa80014159
# ╟─3e80feb1-9f31-407a-a4af-a12736622154
# ╟─87e773e7-6766-4fa6-bce7-113006850e34
# ╟─b5933bdc-1174-44ea-bc18-4d269eb3e3a0
# ╟─19f06c41-1dff-4f9a-a4ef-b1304356a960
# ╟─331d5a99-2c8d-411a-a609-6747082b5a59
# ╟─43fc6254-64e4-4db3-93be-c98265ecb791
# ╟─f0435117-b50d-4bc5-acef-689fae0c3d9e
# ╟─229e54ce-2f4d-4752-a498-b4fbe1a852fd
# ╟─c94dffe8-40db-4874-aad3-b546cff0b4a6
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
