#hide-below
#HINT: Use empty new line for linebreak (otherwise it will be regarded as the same paragraph)
using SWCForecast
using Dates, Markdown
path2toml = "PATH2TOML" # keyword PATH2TOML will be replaced using `replace_path2toml()`
DDTdescript = readdescription(path2toml)
resultdirname = path2toml |> dirname |> basename
trialcode =match(exprgethash, resultdirname).match
scriptpath = DDTdescript["BasicInfo"]["script_path"]
scriptfname = basename(scriptpath)

sourcecode = trygetsourcecode(scriptpath, "KEYNOTE")
keynotes = eachmatch(r"(?<=# KEYNOTE: ).*", sourcecode)|> collect
list_keynotes = join(broadcast(x-> "- "*x.match,keynotes)," \n ")
feats0 = DDTdescript["Model"]["features"]
targs0 = DDTdescript["Model"]["targets"]
list_features, list_targets = feature_summary(feats0, targs0);

Markdown.parse("""
This report is the brief summary of executing `"$scriptfname"` in trial `"$trialcode"`, at the time $(DDTdescript["BasicInfo"]["experiment_time"]). For the resultant data, see files in `"$resultdirname"`.

## Basic Information
- script: `$(DDTdescript["BasicInfo"]["script_path"])`
- data: `$(DDTdescript["BasicInfo"]["data_path"])`

## Brief Summary
$(DDTdescript["DataShift"]); $(DDTdescript["Model"]["Resampling"]["nfolds"]) folds.

### Plots
![](dataoverview.png)

![](result1.png)

## Description
### Keynotes

$list_keynotes

### Model Summary
$(DDTdescript["Model"]["ModelSummary"])

### Hyperparameters
#### Resampling

- `$(DDTdescript["Model"]["Resampling"]["resampling"])` is applied with $(DDTdescript["Model"]["Resampling"]["nfolds"]) folds.
#### Partitioning
$(DDTdescript["DataPartitionDesc"])

#### Tree depths
$(DDTdescript["Tree"]["TreeDepthRange"])

#### Data shift
$(DDTdescript["DataShift"])

### Features (best model)
For training:
$list_features

To Predict:
$list_targets

### Data overview (best model)
![](dataoverview.png)

### Overview on all data
![](dataoverview_all.png)

## Result
![](result2.png)

## Tree structure
```
$(DDTdescript["Tree"]["TreeStructure"])
```

## Full source code
```
$sourcecode
```

""")
#hide-above
