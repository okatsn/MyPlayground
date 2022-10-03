# https://github.com/Rahulub3r/Julia-ML-Utils/blob/main/decisionTreeUtils.jl
using DecisionTree

function _drawLeaf(leaf_node::DecisionTree.Leaf, encoding::Dict, ax::Axis;
                 wth_box=10, ht_box=4, center_x=0, center_y=0,
                 leafboxcolor=Makie.wong_colors()[2], boxbordercolor=:black,
                 textsize=10, textcolor=:black)
    # Get text to print in the leaf
    encoding_rev = Dict(value => key for (key, value) in encoding)

    total_obs = length(leaf_node.values)
    total_obs_majority_class = sum(leaf_node.values .== leaf_node.majority)
    prop_majority_class = round(total_obs_majority_class/total_obs, digits=2)

    line1 = string(encoding_rev[leaf_node.majority])
    line2 = "$(prop_majority_class) ($(total_obs_majority_class))"
    line3 = "N = $(total_obs)"

    # Plot leaf
    left_x, left_y = center_x - wth_box/2, center_y - ht_box/2

    z = line1 * "\n" * line2 * "\n" * line3
    poly!(ax, Rect(left_x, left_y, wth_box, ht_box), color=leafboxcolor,
                    strokecolor=boxbordercolor, strokewidth=1)
    text!(ax, z, position = (center_x, center_y),
            textsize=textsize, align=(:center, :center), color=textcolor)
end

function _drawNode(x::DecisionTree.Node, ax::Axis; wth_box=10, ht_box=4, center_x=0, center_y=0,
                  nodeboxcolor=Makie.wong_colors()[1], boxbordercolor=:black, textsize=10, textcolor=:black,
                  linetextcolor=:black, linetextsize=10,
                  xlinescale=1, ylinescale=2, feature_names=nothing)

    if feature_names === nothing
        node_text = "Feature $(x.featid)"
    else
        node_text = "$(feature_names[x.featid])"
    end

    ## Draw node box ##
    left_x, left_y   = center_x - wth_box/2, center_y - ht_box/2
    right_x, _       = center_x + wth_box/2, center_y + ht_box/2

    poly!(ax, Rect(left_x, left_y, wth_box, ht_box), color=nodeboxcolor, strokecolor=boxbordercolor, strokewidth=1)
    text!(ax, node_text, position=(center_x, center_y), align=(:center, :center), textsize=textsize, color=textcolor)

    ## Draw lines ##
    left_x, _   = center_x - wth_box/2, center_y
    right_x, _  = center_x + wth_box/2, center_y

    # Add horizontal lines (left and right)
    lines!(ax, [left_x,  left_x  - xlinescale*wth_box], [center_y, center_y], color=:black) #horizontal line, left
    lines!(ax, [right_x, right_x + xlinescale*wth_box], [center_y, center_y], color=:black) #horizontal line, right

    # Add vertical lines (left and right)
    left_h_x,  _  = left_x  - xlinescale*wth_box, center_y
    right_h_x, _  = right_x + xlinescale*wth_box, center_y

    lines!(ax, [left_h_x,  left_h_x],  [center_y, center_y - ylinescale*ht_box], color=:black) # vertical line, left
    lines!(ax, [right_h_x, right_h_x], [center_y, center_y - ylinescale*ht_box], color=:black) # vertical line, right

    ## Add texts on lines ##
    left_text = "<=$(round(x.featval, digits=1))"
    right_text = ">$(round(x.featval, digits=1))"

    # Draw bounding box for the text
    center_textbox_x_left,  center_textbox_y = left_h_x,  center_y - ylinescale*ht_box/3
    center_textbox_x_right, center_textbox_y = right_h_x, center_y - ylinescale*ht_box/3

    textbox_wth, textbox_ht = 1.5*linetextsize/5, 1.5*linetextsize/5/2.5
    left_textbox_x,  left_textbox_y  = center_textbox_x_left -  textbox_wth/2, center_textbox_y - textbox_ht/2
    right_textbox_x, right_textbox_y = center_textbox_x_right - textbox_wth/2, center_textbox_y - textbox_ht/2

    poly!(ax, Rect(left_textbox_x, left_textbox_y, textbox_wth, textbox_ht), color=:white, strokecolor=boxbordercolor, strokewidth=1)
    poly!(ax, Rect(right_textbox_x, right_textbox_y, textbox_wth, textbox_ht), color=:white, strokecolor=boxbordercolor, strokewidth=1)

    # Draw text
    text!(ax, left_text,   position=(left_h_x,  center_textbox_y), textsize=linetextsize,
          align=(:center, :center), color=linetextcolor, font="Arial")
    text!(ax, right_text,  position=(right_h_x, center_textbox_y), textsize=linetextsize,
          align=(:center, :center), color=linetextcolor, font="Arial")

    #-- Carryforwards for next node/leaf --# (i.e., centers for the next node/leaf)
    left_center_x, left_center_y = center_x - wth_box/2 - wth_box*xlinescale, center_y - ht_box/2 - ht_box*ylinescale
    right_center_x, right_center_y = center_x + wth_box/2 + wth_box*xlinescale, center_y - ht_box/2 - ht_box*ylinescale

    return left_center_x, left_center_y, right_center_x, right_center_y
end

function drawTree(x::Union{DecisionTree.Node, DecisionTree.Leaf}, encoding::Dict,
                   ax::Axis; nodewth=10, nodeht=4, center_x=0, center_y=0,
                   nodeboxcolor=Makie.wong_colors()[1], leafboxcolorpalette=Makie.wong_colors(),
                   boxbordercolor=:black, nodetextsize=10, nodetextcolor=:black,
                   leaftextsize=10, leaftextcolor=:black, leafwth=7, leafht=4,
                   linetextcolor=:black, linetextsize=10,
                   xlinescale=1, ylinescale=2, feature_names=nothing)
    if DecisionTree.is_leaf(x)
        lfboxcolor = leafboxcolorpalette[x.majority+1]

        _drawLeaf(x, encoding, ax; wth_box=leafwth, ht_box=leafht,
                 center_x=center_x, center_y=center_y,
                 leafboxcolor=lfboxcolor, boxbordercolor=boxbordercolor,
                 textsize=leaftextsize,textcolor=leaftextcolor)
        return
    end

    new_centers = _drawNode(x, ax; wth_box=nodewth, ht_box=nodeht, center_x=center_x, center_y=center_y,
                          nodeboxcolor=nodeboxcolor, boxbordercolor=boxbordercolor,
                          textsize=nodetextsize, textcolor=nodetextcolor,
                          linetextcolor=linetextcolor, linetextsize=linetextsize,
                          xlinescale=xlinescale, ylinescale=ylinescale, feature_names=feature_names)

    left_center_x, left_center_y, right_center_x, right_center_y = new_centers

    drawTree(x.left, encoding, ax; nodewth=nodewth, nodeht=nodeht, center_x=left_center_x, center_y=left_center_y,
            nodeboxcolor=nodeboxcolor, leafboxcolorpalette=leafboxcolorpalette,
           boxbordercolor=boxbordercolor, nodetextsize=nodetextsize, nodetextcolor=nodetextcolor,
           leaftextsize=leaftextsize, leaftextcolor=leaftextcolor,leafwth=leafwth,leafht=leafht,
           linetextcolor=linetextcolor, linetextsize=linetextsize,
           xlinescale=xlinescale/3, ylinescale=ylinescale, feature_names=feature_names)

    drawTree(x.right, encoding, ax; nodewth=nodewth, nodeht=nodeht, center_x=right_center_x, center_y=right_center_y,
            nodeboxcolor=nodeboxcolor, leafboxcolorpalette=leafboxcolorpalette,
           boxbordercolor=boxbordercolor, nodetextsize=nodetextsize, nodetextcolor=nodetextcolor,
           leaftextsize=leaftextsize, leaftextcolor=leaftextcolor,leafwth=leafwth,leafht=leafht,
           linetextcolor=linetextcolor, linetextsize=linetextsize,
           xlinescale=xlinescale/3, ylinescale=ylinescale, feature_names=feature_names)
end
