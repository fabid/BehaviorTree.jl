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

function sequence(tree::Sequence, task_runner)
    for task in tree.tasks
        result = task_runner(task)
        if result == :running
            return :running
        end
        if result == :failure
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
    for task in tree.tasks
        result = task_runner(task)
        if result == :running
            return :running
        end
        if result == :success
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
