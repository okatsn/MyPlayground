"""
Similar to `Remark.generate(target_dir)`, `generatemyslide(target_dir)` generate the slide in the folder `target_dir` but with my template `index.jl` and `style.css`.

# Tips and Tricks
- set image width in `"src/style.css"` at `img {max-width: ...}`
"""
function generatemyslide(target_dir)
    presentationdir(args...) = joinpath(target_dir, args...)
    try
        Remark.generate(target_dir)
        @info "New slide in $target_dir."
    catch e
        typeof(e)
        if isa(e, Base.IOError)
            @info "Overwrite existing files in $target_dir."
        else
            rethrow(e)
        end
    end


    mytemplate = """

    using Remark, Literate, Markdown #hide
    using Revise #hide
    using SWCForecast #hide
    presentationdir(args...) = joinpath("$target_dir", args...); #hide

    #hide-below
    # # TIPs and Hint
    # - use `myslideshow(presentationdir())` to generate the slide
    #hide-above

    # # Example presentation

    # Some pure-text code

    # ```julia
    # 1+2
    # ```

    # Some julia code
    1 + 2

    # --

    # A fragment

    # ---

    # # Some equations

    # Here is an inline fraction: \$\\frac{1}{2}\$

    # And some identities in display mode:

    # \$\$e^{i\\pi} + 1 = 0\$\$

    # \$\$\\sum_{n=0}^\\infty \\alpha^n = \\frac{1}{1-\\alpha}\$\$

    # ---

    # # A plot

    using Plots
    plot(rand(10))
    savefig("myplot.svg"); #hide

    # ![](myplot.svg)

    # ---

    # # Working on the slideshow
    # Edit this script following [Literate.jl](https://fredrikekre.github.io/Literate.jl/v2/)'s rule, and try the following for example:
    # ```julia
    # slideshowdir = Remark.slideshow(presentationdir(),
    #                             options = Dict("ratio" => "16:9"),
    #                             title = "My beautiful slides")
    # ```

    # See also [Remark.jl](https://github.com/piever/Remark.jl).
    """
    if isfile(presentationdir("src","index.jl"))
        errmsg = """
            "index.jl" already exist
            """
        throw(Base.IOError(errmsg, 999))
    end

    open(presentationdir("src","index.jl"), "w") do io
        Base.write(io, mytemplate)
    end

    mystyle = """
    /* Lora used for body */
    @font-face{
      font-family: 'Lora';
      src: url('fonts/Lora/Lora-Regular.ttf');
    }
    @font-face{
      font-family: 'Lora';
      src: url('fonts/Lora/Lora-Bold.ttf');
      font-weight: bold;
    }
    @font-face{
      font-family: 'Lora';
      src: url('fonts/Lora/Lora-Italic.ttf');
      font-style: italic;
    }
    @font-face{
      font-family: 'Lora';
      src: url('fonts/Lora/Lora-BoldItalic.ttf');
      font-weight: bold;
      font-style: italic;
    }

    /* Yanone Kaffeesatz used for h1, h2, h3 */
    @font-face{
      font-family: 'Yanone Kaffeesatz';
      src: url('fonts/Yanone_Kaffeesatz/YanoneKaffeesatz-Regular.ttf');
    }
    @font-face{
      font-family: 'Yanone_Kaffeesatz';
      src: url('fonts/Yanone_Kaffeesatz/YanoneKaffeesatz-Bold.ttf');
      font-weight: bold;
    }

    /* Ubuntu Mono used for code, do we need Italic for code ? */
    @font-face{
      font-family: 'Ubuntu Mono';
      src: url('fonts/Ubuntu_Mono/UbuntuMono-Regular.ttf');
    }
    @font-face{
      font-family: 'Ubuntu Mono';
      src: url('fonts/Ubuntu_Mono/UbuntuMono-Bold.ttf');
      font-weight: bold;
    }
    @font-face{
      font-family: 'Ubuntu Mono';
      src: url('fonts/Ubuntu_Mono/UbuntuMono-Italic.ttf');
      font-style: italic;
    }
    @font-face{
      font-family: 'Ubuntu Mono';
      src: url('fonts/Ubuntu_Mono/UbuntuMono-BoldItalic.ttf');
      font-weight: bold;
      font-style: italic;
    }

    body { font-family: 'Lora'; }
    h1, h2, h3 {
      font-family: 'Yanone Kaffeesatz';
      font-weight: normal;
    }
    .remark-code, .remark-inline-code { font-family: 'Ubuntu Mono'; }



    img {
        max-width: 100%;
    }


    """

    open(presentationdir("src","style.css"), "w") do io
        Base.write(io, mystyle)
    end

    try # If there is a `"index.jl"`, `"index.md"` should not exist; otherwise, error occurs when `Remark.slideshow`.
        rm(presentationdir("src", "index.md"))
    catch

    end

    @info "Template successfully created!"

    md"""
    # Tips:
    - edit `"src/index.jl"`, following the instruction of Literate.jl
    - edit `"src/style.css"` if want to modify the style of your slide
    - apply Remark.jl:
        ```
        slideshowdir = Remark.slideshow(presentationdir(),
                                options = Dict("ratio" => "16:9"),
                                title = "My beautiful slides")
        ```


    """

end


"""
Since currently `Remark.slideshow` has some problem:
- if `documenter=false`, code won't be executed as expected
- if `documenter=true`, some strings in math equations will be misreplaced

`myslideshow(presentation_dir; options=Dict(), title="Title")` does the following:
- run `Remark.slideshow()`
- `Literate.markdown` with `flavor=Literate.CommonMarkFlavor(), execute=true, mdstrings=true, postprocess=hide_section`
- create `index.html` again, while other files in `"build"` left untouched.

# Example
```julia
myslideshow(presentation_dir; options = Dict("ratio" => "16:9"))
```

# Tips and Tricks
- you can use `#hide-below` and `#hide-above` to hide the entire section
"""
function myslideshow(presentation_dir; options=Dict(), title="Title")
    presentationdir(args...) = joinpath(presentation_dir, args...)
    Remark.slideshow(presentation_dir)
    Literate.markdown(presentationdir("src", "index.jl"), presentationdir("build");
            flavor=Literate.CommonMarkFlavor(), execute=true, mdstrings=true, postprocess=hide_section)
    # output as `"build/index.md"`
    # you can also rename the file by for example adding kwarg `, name="index"`

    htmlbuilt = presentationdir("build", "index.html")
    rm(htmlbuilt)

    # fixme: remember to replace "SWCForecast" by the new package name if it is moved into an independent package
    SWCForecast._create_index_html(presentationdir(), presentationdir("build","index.md"); options=options, title= title)

    # remove all the images in src (you can't do this)
    # srcimage_dir = presentationdir("src", "assets", "img")
    # rm.(filelistall(srcimage_dir))
    # rm.(folderlistall(srcimage_dir))

end




"""
This is modified from `Remark._create_index_html`
"""
function _create_index_html(outputdir, md_file; options=Dict(), title="Title")
    _pkg_assets = srcdir("myreport", "remark_assets")
    optionsjs = JSON.json(options)
    template = joinpath(_pkg_assets, "indextemplate.html")
    replacements = ["\$title" => title, "\$options" => optionsjs]

    Base.open(joinpath(outputdir, "build", "index.html"), "w") do io
        for line in eachline(template, keep=true)
            if occursin("\$presentation", line)
                Base.open(md -> write(io, md), md_file)
            else
                write(io, foldl(replace, replacements, init=line))
            end
        end
    end
    # for (name, file) in zip(depnames, depfiles)
    #     dest = joinpath(outputdir, "build", name)
    #     transcribefile(file, dest)
    # end
    # dest = joinpath(outputdir, "build", "fonts")
    # transcribe(joinpath(_pkg_assets, "fonts"), mkdir(dest))
    joinpath(outputdir, "build", "index.html")
end




"""
Given `abspath`, `refbuildpath(abspath)` returns referenced path relative to the `.../build/aseets` folder.

# Example
```julia-repl
julia> abspath = "/home/jovyan/swc-forecast-insider/temp_ppt/build/assets/img/trees_subset_1/tree_root_1.png"

julia> refbuildpath(abspath)
"assets/img/trees_subset_1/tree_root_1.png"
```


"""
function refbuildpath(abspath)
    a = split(abspath, filesep)
    rpath = join(a[findlast(in.(a, [["assets"]])):length(a)], filesep)
    return rpath
end
