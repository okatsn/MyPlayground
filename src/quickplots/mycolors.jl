function mycolorsd_1(n)
    colors = distinguishable_colors(n, [RGB(1,1,1), RGB(0,0,0)], dropseed=true)
    # ref http://gadflyjl.org/dev/gallery/scales/
end

function mycolor_gadfly_default(n)
distinguishable_colors(n, LCHab(70, 60, 240),
                        transform=c -> deuteranopic(c, 0.5),
                        lchoices=Float64[65, 70, 75, 80],
                        cchoices=Float64[0, 50, 60, 70],
                        hchoices=range(0, 330, length=24))
    # or using Gadfly; Scale.color_discrete_hue(n)
end


function mycolor_plots_default(n)
    Plots.palette(:default, n)
end

function mycolor_tab10(n)
    Plots.palette(:tab10, n)
end

"""
# Example:
`mycolor_plots_palette(:tab10, 5)` which is equivalently `Plots.palette(:tab10, 5)`

# See the following for color schemes:
- https://docs.juliahub.com/MakieGallery/Ql23q/0.2.17/generated/colors.html
- https://docs.juliaplots.org/latest/generated/colorschemes/
"""
function mycolor_plots_palette(name, n)
    Plots.palette(name, n)
end

"""
`mycolor_makie_palette()`
"""
function mycolor_makie_palette()
    RGBA{Float32}[RGBA{Float32}(0.0f0,0.44705883f0,0.69803923f0,1.0f0), RGBA{Float32}(0.9019608f0,0.62352943f0,0.0f0,1.0f0), RGBA{Float32}(0.0f0,0.61960787f0,0.4509804f0,1.0f0), RGBA{Float32}(0.8f0,0.4745098f0,0.654902f0,1.0f0), RGBA{Float32}(0.3372549f0,0.7058824f0,0.9137255f0,1.0f0), RGBA{Float32}(0.8352941f0,0.36862746f0,0.0f0,1.0f0), RGBA{Float32}(0.9411765f0,0.89411765f0,0.25882354f0,1.0f0)]
end


function mycolormap_whitelajolla(whiteratio)
    lajolla = CairoMakie.to_colormap(:lajolla)
    white = CairoMakie.RGBA(1,1,1,1)
    len0 = lajolla |> length
    lenw = Int(floor(whiteratio*len0/(1 - whiteratio)))

    # from white to the lowest color of lajolla
    clm2 = range(white, lajolla[1], length = lenw)
    whitelajolla = vcat(clm2, lajolla)
    return whitelajolla

end

set_transparency(x::Colors.RGBA, alpha) = Colors.RGBA(x.r, x.g, x.b, alpha)
