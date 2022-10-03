"""
(DEPRECATED: use `generatemyreport` instead)

`mdreport(DDT::DescriptOneTree, scriptpath)` gives the report in juliamarkdown for script (`scriptpath`) based on results (`DDT.description`). The output folder is `DDT.description_dir("brief_report.md")`.
"""
function mdreport(DDT::DescriptOneTree, scriptpath)
    mdpath = DDT.description_dir("brief_report.md")
    resultdirname = basename(DDT.description_dir())
    trialcode = split(resultdirname, "_")[end]
    scriptfname = basename(scriptpath)
    jlvec = open(scriptpath) do file
        readlines(file)
    end
    sourcecode = join(jlvec, " \n ")

    keynotes = eachmatch(r"(?<=# KEYNOTE: ).*", sourcecode)|> collect
    list_keynotes = join(broadcast(x-> "- "*x.match,keynotes)," \n ")

    list_features, list_targets = feature_summary(DDT)

    # $((renderrow(n) for n in keynotes))
    # renderrow(note_i) = """
    # - $note_i
    # """

    # descvec = open(DDT.description_dir("description.toml")) do file
    #     readlines(file)
    # end

mytemplate = """
---
title: Brief report on decision tree training ($trialcode)
author: Tsung-Hsi, Wu
date: $(Date(Dates.now()))
---

This report is the brief summary of executing `"$scriptfname"` in trial `"$trialcode"`, at the time $(Dates.now()). For the resultant data, see files in `"$resultdirname"`.

## Brief Summary
$(DDT.description["DataShift"]); $(DDT.description["Model"]["Resampling"]["nfolds"]) folds.
![](dataoverview.png)
![](result1.png)

## Description
### Keynotes
$list_keynotes

### Hyperparameters
#### Resampling
- `$(DDT.description["Model"]["Resampling"]["resampling"])` is applied with $(DDT.description["Model"]["Resampling"]["nfolds"]) folds.

#### Partitioning
$(DDT.description["DataPartitionDesc"])

#### Tree depths
$(DDT.description["Tree"]["TreeDepthRange"])

#### Data shift
$(DDT.description["DataShift"])

### Features
For training:
$list_features

To Predict:
$list_targets

Data overview:
![](dataoverview.png)

## Result
### Prediction and Tree Depth－loss Relation
![](result1.png)

## Tree structure
```
$(DDT.description["Tree"]["TreeStructure"])
```

## Full source code
```
$sourcecode
```



"""

open(mdpath, "w") do f
    for line in split(mytemplate,"\n")
        println(f,line)
    end
end
return mdpath
end
