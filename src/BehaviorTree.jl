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
function run_task(task::BT)
    tick(task)
end

function tick(tree::Sequence)
    for task in tree.tasks
        result = run_task(task)
        if result == :failure
            return :failure
        end
    end
    return :success
end
function tick(tree::Selector)
    for task in tree.tasks
        result = run_task(task)
        if result == :success
            return :success
        end
    end
    return :failure
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
