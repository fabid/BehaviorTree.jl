using BehaviorTree
using AbstractTrees
using Test

function doSuccess()
    :success
end
function isTrue()
    :success
end
function doSuccess!()
    :success
end

function doFailure()
    :failure
end
function doRunning()
    :running
end
function isPositive(x)
    if x>0
        return :success
    end
    :failure
end

@testset "BehaviorTree.jl" begin
    tree = Sequence([doSuccess])
    @test tick(tree)[1] == :success
    @test tick(tree)[2] == [:success]
    tree = Sequence([doFailure])
    @test tick(tree)[1] == :failure
    tree = Sequence([doRunning])
    @test tick(tree)[1] == :running
    tree = Sequence([doSuccess, doFailure, doSuccess])
    @test tick(tree)[1] == :failure
    @test length([ c for c in children(tree)]) == 3
    tree = Selector([doFailure])
    @test tick(tree)[1] == :failure
    tree = Selector([doSuccess])
    @test tick(tree)[1] == :success
    tree = Selector([doRunning])
    @test tick(tree)[1] == :running
    tree = Selector([doFailure, doSuccess, doFailure])
    @test tick(tree)[1] == :success
    # nesting
    tree = Selector([doFailure, Sequence([doSuccess]), doFailure])
    @test tick(tree)[1] == :success
    @info tick(tree)
    @test tick(tree)[2] == [:failure,[:success]]
    # args
    tree = Sequence([isPositive])
    @test tick(tree, 1)[1] == :success
    @test tick(tree, -1)[1] == :failure
    tree = Selector([isPositive])
    @test tick(tree, 1)[1] == :success
    @test tick(tree, -1)[1] == :failure
end
@testset "dot" begin
    bt = Selector([
        doFailure,
        Sequence([isTrue, doFailure, doSuccess], "choice"),
        doRunning,
        doSuccess!
    ], "head")
    dot_graph = toDot(bt)
    println(dot_graph)
    png_graph =dot2png(dot_graph)
end
