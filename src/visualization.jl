
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

export dot2png

colors = Dict(
    :failure =>"#ff9a20",
    :running => "#00bbd3",
    :success => "#49b156",
)


function toDotContent(tree::ShadowTree)
    name = BehaviorTree.format(tree.tree.x)
    if length(children(tree)) == 0
        color = colors[tree.shadow.x]

        shape = if startswith(name, "is") "ellipse" else "box" end
        return string([
            """$name:n\n""",
            """$name [shape=$shape]\n""",
            """$name [style=filled,color="$color"]\n"""
        ]...)
    end
    #shape = if(typeof(tree.tree.x) == Selector) "diamond" else "hexagon" end
    shape = "box"
    label = if(typeof(tree.tree.x) == Selector) "?" else "->" end
    color = colors[last(tree.shadow.x)]
    @info color
    out = string(
        """$name:n\n""",
        """$name [shape=$shape, label="$label", style=filled, color="$color"]\n""",
        ["""$name -> $(toDotContent(c))\n""" for c in children(tree)]...)
    @info out
    out
end
function toDotContent(task)
    name = BehaviorTree.format(task)
    shape = if startswith(name, "is") "ellipse" else "box" end
    return string([
        """$name:n\n""",
        """$name [shape=$shape]\n""",
        """$name []\n"""
    ]...)
end
function toDotContent(tree::BehaviorTree.BT)
    name = BehaviorTree.format(tree)
    if length(children(tree)) == 0
        shape = if startswith(name, "is") "ellipse" else "box" end
        return string([
            """$name:n\n""",
            """$name [shape=$shape]\n""",
            """$name []\n"""
        ]...)
    end
    shape = "box"
    label = if(typeof(tree) == Selector) "?" else "->" end
    out = string(
        """$name:n\n""",
        """$name [shape=$shape, label="$label"]\n""",
        ["""$name -> $(toDotContent(c))\n""" for c in children(tree)]...)
    out
end
function toDot(tree::BT, results)
    st = ShadowTree(tree, results)
    content = toDotContent(st)
    return """digraph tree {
    $(content)
    }"""
end
function toDot(tree::BehaviorTree.BT)
    content = toDotContent(tree)
    return """digraph tree {
    $(content)
    }"""
end

export toDot