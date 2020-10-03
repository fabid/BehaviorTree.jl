module BehaviorTree
using AbstractTrees

abstract type BT end

struct Sequence <: BT
    tasks
    name::String
end
struct Selector <: BT
    tasks
    name::String
end
Sequence(tasks) = Sequence(tasks, "")
Selector(tasks) = Selector(tasks, "")
function run_task(task::Function)
    @debug("RUNNING task $(task)")
    result = task()
    return result, result
end
function run_task(task::Function, state)
    @debug("RUNNING task $(task)")
    result = task(state)
    return result, result
end
function run_task(task::BT)
    tick(task)
end

function run_task(task::BT, state)
    tick(task, state)
end

function format(task::BT)
    task.name
end
function format(task::Function)
    string(task)
end

function sequence(tree::Sequence, task_runner)
    @debug("RUNNING sequence $(tree.name)")
    results = []
    for task in tree.tasks
        result, status = task_runner(task)
        push!(results, status)
        if result == :running
            @info("sequence $(tree.name) running at $(format(task))")
            return :running, results
        end
        if result == :failure
            @info("sequence $(tree.name) failed at $(format(task))")
            return :failure, results
        end
    end
    return :success, results
end

function tick(tree::Sequence)
    task_runner(x) = run_task(x)
    sequence(tree, task_runner)
end

function tick(tree::Sequence, state)
    task_runner(x) = run_task(x, state)
    sequence(tree, task_runner)
end

function selector(tree::Selector, task_runner)
    @debug("RUNNING selector $(tree.name)")
    results = []
    for task in tree.tasks
        result, status = task_runner(task)
        push!(results, status)
        if result == :running
            @info("selector $(tree.name) running at $(format(task))")
            return :running, results
        end
        if result == :success
            @info("selector $(tree.name) succeeded at $(format(task))")
            return :success, results
        end
    end
    return :failure, results
end
function tick(tree::Selector)
    task_runner(x) = run_task(x)
    selector(tree, task_runner)
end

function tick(tree::Selector, state)
    task_runner(x) = run_task(x, state)
    selector(tree, task_runner)
end

include("abstractrees.jl")
include("visualization.jl")

export tick, Sequence, Selector
end # module
