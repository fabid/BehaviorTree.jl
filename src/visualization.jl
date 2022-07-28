
function validateGraphVizInstalled()
    # Check if GraphViz is installed
    try
        (read(`dot -'?'`, String)[1:10] == "Usage: dot") || error()
    catch
        error("GraphViz is not installed correctly. Make sure GraphViz is installed. If you are on Windows, manually add the path to GraphViz to your path variable. You should be able to run 'dot' from the command line.")
    end
end

function dot2png(dot_graph::AbstractString)
    # Generate PNG image from DOT graph
    validateGraphVizInstalled()
    proc = open(`dot -Tpng`, "r+")
    write(proc.in, dot_graph)
    close(proc.in)
    return read(proc.out, String)
end
function dot2jpg(dot_graph::AbstractString)
    # Generate PNG image from DOT graph
    validateGraphVizInstalled()
    proc = open(`dot -Tjpg`, "r+")
    write(proc.in, dot_graph)
    close(proc.in)
    return read(proc.out, String)
end

export dot2png,dot2jpg

colors = Dict(
    :failure =>"#ff9a20",
    :running => "#00bbd3",
    :success => "#49b156",
)

function toDotContent(tree, parent_id)
    name = BehaviorTree.format(tree)
    node_id = string(parent_id, replace(name, "!"=>""))
    if length(children(tree)) == 0
        shape = if startswith(name, "is") "ellipse" else "box" end
        return string([
            """$node_id:n\n""",
            """$node_id [shape=$shape, label="$name"]\n""",
            """$parent_id -> $node_id""",
        ]...)
    end
    shape = "box"
    label = if(typeof(tree) == Selector) "?" else "->" end
    out = string(
        """$node_id:n\n""",
        """$node_id [shape=$shape, label="$label"]\n""",
        ["""$(toDotContent(c, node_id))\n""" for c in children(tree)]...)
    if parent_id != ""
        out = string(
            out,
            """$parent_id -> $node_id""",
        )
    end
    out
end

function toStatusDotContent(tree, results, parent_id)
    name = BehaviorTree.format(tree)
    node_id = string(parent_id, replace(name, "!"=>""))
    if length(children(tree)) == 0
        shape = if startswith(name, "is") "ellipse" else "box" end
        color = colors[results]
        return string([
            """$node_id:n\n""",
            """$node_id [shape=$shape, label="$name", style=filled,color="$color"]\n""",
            """$parent_id -> $node_id""",
        ]...)
    end
    shape = "box"
    label = if(typeof(tree) == Selector) "?" else "->" end
    #TODO: more efficient implementation?
    lastchild = results
    while length(children(lastchild)) > 0
        lastchild = last(children(lastchild))
    end
    color = colors[lastchild]
    out = string(
        """$node_id:n\n""",
        """$node_id [shape=$shape, label="$label", style=filled, color="$color"]\n""",
        ["""$(toStatusDotContent(a, b, node_id))\n""" for (a,b) in zip(children(tree), children(results))]...)
    if parent_id != ""
        out = string(
            out,
            """$parent_id -> $node_id""",
        )
    end
    out
end
function toDot(tree::BT, results)
    content = toStatusDotContent(tree, results, "")
    return """digraph tree {
    $(content)
    }"""
end
function toDot(tree::BT)
    content = toDotContent(tree, "")
    return """digraph tree {
    $(content)
    }"""
end

export toDot
