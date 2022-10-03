module SWCForecast

using Dates

using DataFrames
using DrWatson
using MLJ
using DecisionTree: DecisionTree

using RecipesBase
using NetworkLayout

include("project_setup.jl")
export notebooksdir
export externaldatadir, rawdatadir, interimdatadir, finaldatadir
export outputdir, featuresdir, modelsdir, reportsdir, figuresdir, testdatadir
export projectdir, datadir, srcdir, scriptsdir  # reexport DrWatson
export trainingdir
export mdtemplatedir
export AFile, AFolder

using MLJDecisionTreeInterface
include("decisiontree.jl")
export tree_structure
export AbstractDescription, DescriptOneTree, DescriptCompTree, DescriptOneForest,DescriptEnsembleTrees
export FeatureCounts, treeinspect!

include("plots_recipes/decisiontree.jl")

include("utils/models.jl")
export load_decision_tree_regressor

include("utils/dataframe.jl")
export narrow_types!, convert_types

using DataFrames
include("dataframetools.jl")
export convertdf2!
export checkparse
export reducetype!
export reducetype
export describeinstr
export isnan
export selectnames, selectname
export get1var
export chknnm


using DataFrames
include("featureselect.jl")
export featureselectbyheadkey, excludekey!

using Gadfly
include("gadflytools.jl")
export plotlegendonly

using Gadfly, Chain
include("plots_recipes/quickplot.jl")
export quickdataoverview


import FHist, CairoMakie, Colors, ColorSchemes
import Statistics
include("quickplots/histcontour.jl")
export forcontourf, set_transparency
include("quickplots/multibands.jl")
export symmquantile, quantileband!


using Colors, Gadfly
include("quickplots/mycolors.jl")
export mycolorsd_1, mycolor_gadfly_default, mycolor_plots_default, mycolor_tab10, mycolor_plots_palette, mycolor_makie_palette
export mycolormap_whitelajolla



include("keynote.jl")
export Keynote

using TOML, Remark, Markdown
include("myreport/description.jl")
export description!, writedescription, readdescription!, readdescription

include("myreport/mdreport.jl")
export mdreport # DEPRECATED; preserved only for backward capability (decision tree 20220330 and before)

include("recursive_merge.jl")
export recursive_merge, recursive_merge!

include("mkresultdir.jl")
export mkresultdir

include("print2string.jl")
export print2string

include("format_time_tag.jl")
export format_time_tag

using Markdown, FileTools
include("collectresult.jl")
export result_folder_expr, returnchild,targetrange, targetsection, islevelleq,islevel,appendheader! # base level
export mdpaths, getsection, merge!, elwmerge!, mdimgpath! # higher level
export compareresult # highest level
export SubMD # type
export exprgethash # regular expression for getting the hashtag
export copyimg, join
export copysections
export expr_defaultmdname, defaultmdname

using Impute
include("myimputation/myimpute.jl")
export imputemean!, imputeinterp!, removeunreasonables!

using CSV, CategoricalArrays, CairoMakie
include("quickplots/filecolumnview.jl")
export filecolumnview # high level
export isvarexist
export getallfeat # low level




using Impute, CSV, Chain
include("deprecate.jl")

using FileTools, DataFrames
include("metascript.jl")
export manyscript, replacerewrite
export runallscript

using Dates, Statistics
include("datenum.jl")
export toordinal, datenum, mean

using Literate, JSON, Markdown
include("myreport/markdownreport.jl")
export markdownreport, hide_section, emptyMD
include("myreport/slideshow.jl")
export myslideshow, generatemyslide,refbuildpath
export iscommented,iscommentedand, onlycodelines, removetag, trygetsourcecode

using DataFrames
include("myreport/feature_summary.jl")
export feature_summary, reduce_feature, group_feature, InfoShiftedFeature,rmprefix,quicksave

import MLJEnsembles
include("myreport/get_fitresult.jl")
export getparam_atom, getmodel_atom

using Images
include("imgproc/imgcrop.jl")
export cropwhite

using OffsetArrays, ImageFiltering
include("movingaverage.jl")
export mvmean, mvnanmean, slowmvnanmean


using PlotUtils: optimize_ticks
using CairoMakie, Dates
include("makietools.jl")
export datetimeticks!, datetime2epochs, blankaxis!, getxylimits, expandylim!, shrinkylim!
export secondyaxis

using ShiftedArrays
include("series2supervised.jl")
export series2supervised, diffsstable!, gettshiftval

using DataFrames
include("dataprocessing/precipitation.jl")
export addcol_accumulation!, cccount



end
