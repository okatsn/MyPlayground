using SWCForecast
using DataFrames, XLSX

allpaths = readdir(rawdatadir(); join=true);
filenames = basename.(allpaths) # `basename(path)` get the file name of a path.
targetpaths = allpaths[occursin.(r"^\d{6}\.xlsx", filenames)] # "^\d{6}\.xlsx" matches the target string that start with number of total 6 digits, followed by ".xlsx" immediately.

for path_i in targetpaths
    # path_i = targetpaths[1]; for example
    name_i = basename(path_i)
    try
        xf = XLSX.readxlsx(path_i) # read an xlsx file as a XLSXFile object
        sheetname_i = XLSX.sheetnames(xf)[1] # get the first sheet name
        df = DataFrame(XLSX.gettable(xf[sheetname_i])...) # convert the XLSX.Worksheet object to DataFrame.
        println(
            "Sucessfully loading $(name_i); it has $(nrow(df)) rows and $(ncol(df)) columns; the first column name is $(names(df)[1]).",
        )
    catch e
        @warn "an error occurs when converting $name_i: $e"
    end
end
