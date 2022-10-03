#=
References:
https://github.com/Evovest/EvoTrees.jl/blob/main/src/plot.jl

Issues:
"How to plot a decision tree (using a graphics package)"
https://github.com/bensadeghi/DecisionTree.jl/issues/147
=#

function breadth_first_traverse(tree::DecisionTree.Node, depth=-1)
    @debug "target_depth=$depth"

    # initialize arrays
    vec_split = Vector()
    vec_featid = Vector()
    vec_featval = Vector()
    vec_majority = Vector()
    vec_values = Vector()
    unvisited = Vector()
    vec_depth = Vector{Int}()
    vec_isnode = Vector{Bool}()

    # initialize
    current_depth = 0  # root node
    push!(vec_depth, current_depth)
    push!(unvisited, tree)
    push!(vec_isnode, true)

    # collection information via Breadth-First Search
    while !isempty(unvisited)
        current_node = popfirst!(unvisited)
        current_depth = popfirst!(vec_depth)
        current_isnode = popfirst!(vec_isnode)
        if current_depth > depth
            @debug "current_depth > target_depth; current_isnode=$current_isnode; current_depth=$current_depth"
            continue
        elseif current_depth == depth
            @debug "current_depth == target_depth; current_isnode=$current_isnode; current_depth=$current_depth"
            if current_isnode
                push!(vec_split, false)
                push!(vec_featid, current_node.featid)
                push!(vec_featval, current_node.featval)
                push!(vec_majority, NaN)
                push!(vec_values, NaN)
                if !DecisionTree.is_leaf(current_node.left)
                    push!(unvisited, current_node.left)
                    push!(vec_depth, current_depth + 1)
                    push!(vec_isnode, true)
                else
                    push!(unvisited, current_node.left)
                    push!(vec_depth, current_depth + 1)
                    push!(vec_isnode, false)
                end
                if !DecisionTree.is_leaf(current_node.right)
                    push!(unvisited, current_node.right)
                    push!(vec_depth, current_depth + 1)
                    push!(vec_isnode, true)
                else
                    push!(unvisited, current_node.right)
                    push!(vec_depth, current_depth + 1)
                    push!(vec_isnode, false)
                end
            else
                push!(vec_split, false)
                push!(vec_featid, [])
                push!(vec_featval, [])
                push!(vec_majority, current_node.majority)
                push!(vec_values, current_node.values)
            end
        elseif current_depth < depth
            @debug "current_depth < target_depth; current_isnode=$current_isnode; current_depth=$current_depth"
            if current_isnode
                push!(vec_split, true)
                push!(vec_featid, current_node.featid)
                push!(vec_featval, current_node.featval)
                push!(vec_majority, [])
                push!(vec_values, [])
                if !DecisionTree.is_leaf(current_node.left)
                    push!(unvisited, current_node.left)
                    push!(vec_depth, current_depth + 1)
                    push!(vec_isnode, true)
                else
                    push!(unvisited, current_node.left)
                    push!(vec_depth, current_depth + 1)
                    push!(vec_isnode, false)
                end
                if !DecisionTree.is_leaf(current_node.right)
                    push!(unvisited, current_node.right)
                    push!(vec_depth, current_depth + 1)
                    push!(vec_isnode, true)
                else
                    push!(unvisited, current_node.right)
                    push!(vec_depth, current_depth + 1)
                    push!(vec_isnode, false)
                end
            else
                @debug "current_depth < target_depth; current_isnode=$current_isnode; current_depth=$current_depth"
                push!(vec_split, false)
                push!(vec_featid, [])
                push!(vec_featval, [])
                push!(vec_majority, current_node.majority)
                push!(vec_values, current_node.values)
            end
        end
    end
    return (
        tree_split=vec_split,
        node_featid=vec_featid,
        node_featval=vec_featval,
        leaf_majority=vec_majority,
        leaf_values=vec_majority,
    )
end

function get_adj_list(tree_split)
    n = 1
    map = ones(Int, 1)
    adj = Vector{Vector{Int}}()
    if tree_split[1]
        push!(adj, [n + 1, n + 2])
        n += 2
    else
        push!(adj, [])
    end

    for i in 2:length(tree_split)
        if tree_split[i]
            push!(map, i)
            push!(adj, [n + 1, n + 2])
            n += 2
        else  # modified from `elseif tree_split[i >> 1]`
            push!(map, i)
            push!(adj, [])
        end
    end
    return (map=map, adj=adj)
end

function get_shapes(tree_layout)
    shapes = Vector(undef, length(tree_layout))
    for i in 1:length(tree_layout)
        x, y = tree_layout[i][1], tree_layout[i][2] # center point
        x_buff = 0.46 # the width of rectangle box
        y_buff = 0.45
        shapes[i] = [
            (x - x_buff, y + y_buff),
            (x + x_buff, y + y_buff),
            (x + x_buff, y - y_buff),
            (x - x_buff, y - y_buff),
        ]
    end
    return shapes
end

function get_annotations(tree_layout, map, tree_collection, var_names)
    # annotations = Vector{Tuple{Float64, Float64, String, Tuple}}(undef, length(tree_layout))
    annotations = []
    for i in 1:length(tree_layout)
        x, y = tree_layout[i][1], tree_layout[i][2] # center point
        if tree_collection.tree_split[map[i]]
            feat = if isnothing(var_names)
                "feat: " * string(tree_collection.node_featid[map[i]])
            else
                var_names[tree_collection.node_featid[map[i]]]
            end
            thr = string(round(tree_collection.node_featval[map[i]]; sigdigits=3))
            txt =
                "$feat\n" * "L ≤ $thr < R" # the text shown in box
        else
            txt =
                "pred:\n" *
                string(round(tree_collection.leaf_majority[map[i]]; sigdigits=3))
        end
        # annotations[i] = (x, y, txt, (9, :white, "helvetica"))
        push!(annotations, (x, y, txt, 10))
    end
    return annotations
end

function get_curves(adj, tree_layout, shapes)
    curves = []
    num_curves = sum(length.(adj))
    for i in 1:length(adj)
        for j in 1:length(adj[i])
            # curves is a length 2 tuple: (vector Xs, vector Ys)
            push!(
                curves,
                (
                    [tree_layout[i][1], tree_layout[adj[i][j]][1]],
                    [shapes[i][3][2], shapes[adj[i][j]][1][2]],
                ),
            )
        end
    end
    return curves
end

@recipe function plot(tree::DecisionTree.Node, var_names=nothing, depth=5)
    tree_collection = breadth_first_traverse(tree, depth)
    map, adj = get_adj_list(tree_collection.tree_split)
    tree_layout = length(adj) == 1 ? [[0.0, 0.0]] : NetworkLayout.buchheim(adj)
    shapes = get_shapes(tree_layout) # issue with Shape coming from Plots... to be converted o Shape in Receipe?
    annotations = get_annotations(tree_layout, map, tree_collection, var_names) # same with Plots.text
    curves = get_curves(adj, tree_layout, shapes)

    size_base = floor(log2(length(adj)))
    size = (128 * 2^size_base, 128 * (1 + size_base))  #  modified from `size = (128 * 2^size_base, 96 * (1 + size_base))`

    background_color --> :white
    linecolor --> :black
    legend --> nothing
    axis --> nothing
    framestyle --> :none
    size --> size
    annotations --> annotations

    for i in 1:length(shapes)
        @series begin
            fillcolor = length(adj[i]) == 0 ? "#84DCC6" : "#C8D3D5"
            fillcolor --> fillcolor
            seriestype --> :shape
            return shapes[i]
        end
    end

    for i in 1:length(curves)
        @series begin
            seriestype --> :curves
            return curves[i]
        end
    end
end
