function get_data(datafile, feature_names, target_names)
    return @chain datafile begin
        CSV.read(DataFrame; dateformat="yyyy/mm/dd HH:MM")
        Impute.substitute(; statistic=mean)  # MLJ also has `FillImputer` for imputation
        disallowmissing
        (
            select(_, union(["TIMESTAMP"], feature_names)),
            select(_, union(["TIMESTAMP"], target_names)),
        )
    end
end
