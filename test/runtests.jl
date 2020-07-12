using BehaviorTree
using AbstractTrees
using Test



function doSuccess()
    :success
end
function doFailure()
    :failure
end
@testset "BehaviorTree.jl" begin
    tree = Sequence([doSuccess])
    @test tick(tree) == :success
    tree = Sequence([doFailure])
    @test tick(tree) == :failure
    tree = Sequence([doSuccess, doFailure, doSuccess])
    @test tick(tree) == :failure
    @test length([ c for c in children(tree)]) == 3
    tree = Selector([doFailure])
    @test tick(tree) == :failure
    tree = Selector([doSuccess])
    @test tick(tree) == :success
    tree = Selector([doFailure, doSuccess, doFailure])
    @test tick(tree) == :success
    # nesting
    tree = Selector([doFailure, Sequence([doSuccess]), doFailure])
    @test tick(tree) == :success
    #@test printnode(tree) == "->"
    #@test Sequence([]).tick() == :success
    #@test Sequence([x -> :success]) == :success
    #@test Sequence([x -> :fail]) == :fail
end
