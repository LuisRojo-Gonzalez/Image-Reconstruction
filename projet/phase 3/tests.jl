include("./heuristic1.jl")
include("./heuristic2.jl")
include("./prim.jl")
include("../phase 1/graph.jl")

using Test
using BenchmarkTools
@testset "Tests Component structure" begin
    g = Graph{Char}()
    for i in 1:9
        n = Node(string('a' + i-1), 'a' + i-1)
        add_node!(g, n)
    end
    add_edge!(g, Edge((get_node(g, "a"), get_node(g, "b")), 4))
    add_edge!(g, Edge( (get_node(g, "a"), get_node(g, "h")), 8))
    add_edge!(g, Edge((get_node(g, "b"), get_node(g, "h")), 11))
    add_edge!(g, Edge((get_node(g, "b"), get_node(g, "c")), 8))
    add_edge!(g, Edge((get_node(g, "h"), get_node(g, "i")), 7))
    add_edge!(g, Edge((get_node(g, "g"), get_node(g, "h")), 1))
    add_edge!(g, Edge((get_node(g, "i"), get_node(g, "g")), 6))
    add_edge!(g, Edge((get_node(g, "i"), get_node(g, "c")), 2))
    add_edge!(g, Edge((get_node(g, "g"), get_node(g, "f")), 2))
    add_edge!(g, Edge((get_node(g, "c"), get_node(g, "f")), 4))
    add_edge!(g, Edge((get_node(g, "c"), get_node(g, "d")), 7))
    add_edge!(g, Edge((get_node(g, "d"), get_node(g, "f")), 14))
    add_edge!(g, Edge((get_node(g, "d"), get_node(g, "e")), 9))
    add_edge!(g, Edge((get_node(g, "f"), get_node(g, "e")), 10))
    @testset "Kruskal" begin
        @testset "Exemple du cours" begin
            tree_k = kruskal(g)
            #b = @benchmark kruskal($g)
            #@show b
            @test sum(weight.(edges(tree_k))) == 37
            @test length(nodes(tree_k)) == length(nodes(g))
            @test length(edges(tree_k)) == 8
            tree = kruskal_heur1(g)
           # b = @benchmark kruskal_heur1($g)
          # @show b
            @test sum(weight.(edges(tree))) == 37
            @test length(nodes(tree)) == length(nodes(g))
            @test length(edges(tree)) == 8
            tree_h2 = kruskal_heur2(g)
            #b = @benchmark kruskal_heur2($g)
           # @show b
            @test sum(weight.(edges(tree_h2))) == 37
            @test length(nodes(tree_h2)) == length(nodes(g))
            @test length(edges(tree_h2)) == 8
            tree_prim = prim(g)
           
            @test sum(weight.(edges(tree_prim))) == 37
            @test length(nodes(tree_prim)) == length(nodes(g))
            @test length(edges(tree_prim)) == 8
        end
        
    end

end
