module BehaviorTree
using AbstractTrees
import AbstractTrees: children, printnode

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
    task()
end
function run_task(task::Function, state)
    task(state)
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
    for task in tree.tasks
        result = task_runner(task)
        if result == :running
            @info("sequence $(tree.name) running at $(format(task))")
            return :running
        end
        if result == :failure
            @info("sequence $(tree.name) failed at $(format(task))")
            return :failure
        end
    end
    return :success
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
    for task in tree.tasks
        result = task_runner(task)
        if result == :running
            @info("selector $(tree.name) running at $(format(task))")
            return :running
        end
        if result == :success
            @info("selector $(tree.name) succeeded at $(format(task))")
            return :success
        end
    end
    return :failure
end
function tick(tree::Selector)
    task_runner(x) = run_task(x)
    selector(tree, task_runner)
end

function tick(tree::Selector, state)
    task_runner(x) = run_task(x, state)
    selector(tree, task_runner)
end

function AbstractTrees.children(tree::BT)
    tree.tasks
end

function AbstractTrees.printnode(io::IO, node::Sequence)
    if node.name != ""
        repr = "$(node.name) ->"
    else
        repr = "->"
    end
    print(io, repr)
end
function AbstractTrees.printnode(io::IO, node::Selector)
    if node.name != ""
        repr = "$(node.name) ?"
    else
        repr = "?"
    end
    print(io, repr)
end

export tick, Sequence, Selector
end # module
