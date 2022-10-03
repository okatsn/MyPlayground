
path_i = interimdatadir("2018 data.csv")
df = CSV.read(path_i, DataFrame; dateformat="yyyy/mm/dd HH:MM")
isnanalias = isequal.("#VALUE!", df) .| isequal.("NaN", df) .| isequal.("nan", df)
df = ifelse.(isnanalias, NaN, df) # convert "#VALUE!" to NaN
df = ifelse.(isequal.("None", df), missing, df)
# df = ifelse.(isequal.("nan", df), missing, df)
selector_ymdhm = names(df[!, 2:6])
dropmissing!(df, :year) # filter!(row -> !ismissing(row[:year]), df)
filter!(:year => !isnan, df)
select!(df, Not("TIMESTAMP"))
checkparse(df, Float64)

df_ymdhm = df[!, selector_ymdhm] # view on df's year, month, ..., hour
df_feat = df[!, Not(selector_ymdhm)] # df's features
# the cause of error might be the failure concerning autopromotion of a column variable in the dataframe
convertdf2!(df_feat, Float64)
convertdf2!(df_ymdhm, Int)

transform!(
    df,
    [:year, :month, :day, :hour, :minute] =>
        ((y, m, d, h, mi) -> DateTime.(y, m, d, h, mi)) => :datetime,
)
select!(df, :datetime, Not(:datetime))
select!(df, Not(selector_ymdhm))
describe(df)
