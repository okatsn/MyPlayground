using Markdown

@testset "collectresult.jl: result_folder_expr" begin
    flist = [
        "/home/jovyan/swc-forecast-insider/training/decisiontree_20220309/RESULT_ExpeDeci_0x15b03b01222fec37"
        , "/home/jovyan/swc-forecast-insider/training/decisiontree_20220309/RESULT_ExpeDeci_0x42a34736cd10179a"
        , "/home/jovyan/swc-forecast-insider/training/decisiontree_20220309/RESULT_ExpeDeci_0x8a37ffc85c22eddf"
        , "/home/jovyan/swc-forecast-insider/training/decisiontree_20220309/RESULT_ExpeDeci_0xa14053903286ac23"
        , "/home/jovyan/swc-forecast-insider/training/decisiontree_20220309/RESULT_ExpeDeci_0xa5d6af2d810b9cf2"
        , "/home/jovyan/swc-forecast-insider/training/decisiontree_20220309/RESULT_ExpeDeci_0xb914c23a5848469d"
        , "/home/jovyan/swc-forecast-insider/training/decisiontree_20220309/RESULT_ExpeDeci_0xbc2888ab631e5fee"
        , "/home/jovyan/swc-forecast-insider/training/decisiontree_20220309/RESULT_ExpeDeci_0xe21e03c2dbd21353"
        , "/home/jovyan/swc-forecast-insider/training/decisiontree_20220309/RESULT_ExpeDeci_0xcca2c543ebf85ab4"
        , "/home/jovyan/swc-forecast-insider/training/decisiontree_20220309/RESULT_ExpeDeci_0xd8a362b941617df6"
    ]
    strvec = ["ac23", "7df6", "ddf", "c37", "4161"]
    expr = result_folder_expr(strvec)
    occursin.(expr, flist)
    @test isequal(occursin.(expr, flist), [true, false, true, true, false, false, false, false, false, true])

    @test occursin(expr, "\\swc-forecast-insider\\training\\decisiontree_20220309\\RESULT_ExpeDeci_0xd8a362b941617df6")# should match

    @test occursin(expr, "/0xswc-forecast-insider7df6/training/decisiontree_20220309/RESULT_ExpeDeci_0xd8a362b941617df6")# should match

    @test occursin(expr, "/swc-forecast-insider/training/decisiontree_20220309/RESULT_ExpeDeci_0xd8a362b941617df6_newtest")# should match

    @test !occursin(expr, "/swc-forecast-insider/training/decisiontree_20220309/RESULT_ExpeDeci_0x7df6d8a362b95132_newtest") # should not match since "7df6" is not in the end

    @test !occursin(expr, "/swc-forecast-insider/training/decisiontree_20220309/RESULT_ExpeDeci_0xd8a7df6362b95132") # should not match since "7df6" is not in the end

    @test match(expr, "/swc-forecast-insider/training/decisiontree_20220309/RESULT_ExpeDeci_0xd8a362b94161").match == "0xd8a362b94161"

    @test match(expr, "/swc-forecast-insider/training/decisiontree_20220309/RESULT_ExpeDeci_0xd8a362b94161_yet_a_suffix").match == "0xd8a362b94161"
end

@testset "test `exprgethash`" begin
    @test match(exprgethash, "RESULT_ExpeDeci_0xd8a362b94161").match == "0xd8a362b94161"
    @test match(exprgethash,"RESULT_ExpeDeci_0x7df6d8a362b95132_newtest").match == "0x7df6d8a362b95132"
end

md1 = md"""
---
title: Brief report on decision tree training (0x15b03b01222fec37)
author: Tsung-Hsi, Wu
date: 2022-03-16
---

This report is the brief summary of executing `"myexperiment.jl"` in trial `"0x15b03b01222fec37"`, at the time 2022-03-16T17:05:40.047. For the resultant data, see files in `"RESULT_ExpeDeci_0x15b03b01222fec37"`.

## Description Hello `code` *it* aaa-bbb45 **BolD haha `mia`**
### Keynotes
- Preprocessing: Impute missing values with mean.
 - Irrelevant time features ("year", "day", "minute",...) are removed.
 - Size of the training time window is changed

### Hyperparameters
#### Resampling
- `TimeSeriesCV` is applied with 24 folds.

#### Partitioning
80.0% of data is applied for training and validation, and 20.0% of data is for testing.


#### Tree depths
20 ≤ max_depth ≤ 100

#### Data shift
The past **240-minutes** ($t_{-24,...,-1}$) data are applied for predicting the future **10-minutes** ($t_{+1}$) SWC.


### Features
For training:
- month: $t_{i=-24,-23,...,-1}$ (total 24)
- hour: $t_{i=-24,-23,...,-1}$ (total 24)
- precipitation: $t_{i=-24,-23,...,-1}$ (total 24)
- air temperature: $t_{i=-24,-23,...,-1}$ (total 24)
- Soil temperature 10cm: $t_{i=-24,-23,...,-1}$ (total 24)
- Soil temperature 30cm: $t_{i=-24,-23,...,-1}$ (total 24)

To Predict:
- `"Soil_water_content_10cm_t"`

## Result
### Performance－Tree Depth
![](tuned_max_depth.png)

### Predict Result
- Best maximum depth is 33.
![](predict_result.png)
"""


@testset "collectresult.jl: islevelleq, islevel" begin
    @test islevel(md1.content[4], 2)
    @test islevelleq(md1.content[4], 3)
    @test islevelleq(md1.content[4], 4)
    @test islevelleq(md1.content[4], 5)
    @test !islevelleq(md1.content[4], 1)

    @test islevel(md1.content[16], 3)
    @test islevelleq(md1.content[16], 3)
    @test islevelleq(md1.content[16], 4)
    @test islevelleq(md1.content[16], 5)
    @test !islevelleq(md1.content[16], 2)
    @test !islevelleq(md1.content[16], 1)
end

@testset "collectresult.jl: targetrange" begin
    @test isequal(targetrange(md1.content, 2, r"Descrip"), 4:20)
    @test isequal(targetrange(md1.content, 3, r"Keynot"), 5:6)
    @test isequal(targetrange(md1.content, 3, r"Featu"), 16:20)
    @test isequal(targetrange(md1.content, 2, r"Result"), 21:length(md1.content))
end

@testset "collectresult.jl: mdimgpath!" begin
    md1 = md"""
    ---
    title: Brief report on decision tree training (0x15b03b01222fec37)
    author: Tsung-Hsi, Wu
    date: 2022-03-16
    ---

    This report is the brief summary of executing `"myexperiment.jl"` in trial `"0x15b03b01222fec37"`, at the time 2022-03-16T17:05:40.047. For the resultant data, see files in `"RESULT_ExpeDeci_0x15b03b01222fec37"`.

    ## Description Hello `code` *it* aaa-bbb45 **BolD haha `mia`**
    ### Keynotes
    - Preprocessing: Impute missing values with mean.
    - Irrelevant time features ("year", "day", "minute",...) are removed.
    - Size of the training time window is changed

    ### Hyperparameters
    #### Resampling
    - `TimeSeriesCV` is applied with 24 folds.

    #### Partitioning
    80.0% of data is applied for training and validation, and 20.0% of data is for testing.


    #### Tree depths
    20 ≤ max_depth ≤ 100

    #### Data shift
    The past **240-minutes** ($t_{-24,...,-1}$) data are applied for predicting the future **10-minutes** ($t_{+1}$) SWC.


    ### Features
    For training:
    - month: $t_{i=-24,-23,...,-1}$ (total 24)
    - hour: $t_{i=-24,-23,...,-1}$ (total 24)
    - precipitation: $t_{i=-24,-23,...,-1}$ (total 24)
    - air temperature: $t_{i=-24,-23,...,-1}$ (total 24)
    - Soil temperature 10cm: $t_{i=-24,-23,...,-1}$ (total 24)
    - Soil temperature 30cm: $t_{i=-24,-23,...,-1}$ (total 24)
    - Plot in the list ![](blue_bird.png)

    To Predict:
    - `"Soil_water_content_10cm_t"`

    ## Result
    ### Performance－Tree Depth
    ![](tuned_max_depth.png)

    ### Predict Result
    - Best maximum depth is 33.
    ![](predict_result.png)
    """

    mdimgpath!(md1.content, "RESULT_xxx")
    @test md1.content[26].content[1].url == joinpath("RESULT_xxx", "predict_result.png")
    @test md1.content[23].content[1].url == joinpath("RESULT_xxx","tuned_max_depth.png")
    @test md1.content[18].items[7][1].content[2].url == joinpath("RESULT_xxx","blue_bird.png")
end


@testset "test mdimgpath!" begin
    thatresultdir(args...) = joinpath("foo", "bar", args...)
    md1 = md"""
    # Hello
    this is a image:
    ![](foobar.png)
    """
    mdimgpath!(md1.content, thatresultdir)
    @test returnchild(md1.content[2])[2].url == thatresultdir("foobar.png")
end

@testset "collectresult.jl: elwmerge!" begin
    mda1 = md"""
    ### Discussion
    I'd like to be your friend, Jack.
    """

    mda2 = md"""
    ### Discussion
    I'd like to be your friend, Mary.
    """

    mdb1 = md"""
    ### Conclusion
    Hello my friend.
    """

    mdb2 = md"""
    ### Conclusion
    Hello my friend.
    """

    mdas = [mda1, mda2]
    elwmerge!(mdas, [mdb1, mdb2])

    mdc1 = md"""
    ### Discussion
    I'd like to be your friend, Jack.
    ### Conclusion
    Hello my friend.
    """
    mdc2 = md"""
    ### Discussion
    I'd like to be your friend, Mary.
    ### Conclusion
    Hello my friend.
    """

    @test isequal(mdas, [mdc1, mdc2])
end
