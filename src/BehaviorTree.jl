module BehaviorTree
using AbstractTrees
import AbstractTrees: children, printnode

abstract type BT end

struct Sequence <: BT
    tasks
end
struct Selector <: BT
    tasks
end
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
    print(io, "->")
end
function AbstractTrees.printnode(io::IO, node::Selector)
    print(io, "?")
end

export tick, Sequence, Selector
end # module
