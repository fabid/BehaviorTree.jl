## AbstractTrees interface

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