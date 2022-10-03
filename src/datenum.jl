"""
`datenum(d::Dates.DateTime)` converts a Julia DateTime to a MATLAB style DateNumber. Also see: `toordinal`
"""
function datenum(dt::DateTime)
    dnum = Dates.datetime2epochms(dt)/(1000*60*60*24) + 1
    return dnum
end

"""
`datenum(v...)` does `datenum(DateTime(v...))`.
"""
function datenum(v...)
    dt = DateTime(v...)
    return datenum(dt)
end

"""
`toordinal(dt::DateTime)`converts a Julia DateTime to a python style DateNumber. Also see `datenum`.
"""
function toordinal(dt::DateTime)
    return datenum(dt) - 366
end

"""
`toordinal(v...)` does `toordinal(DateTime(v...))`.
"""
function toordinal(v...)
    dt = DateTime(v...)
    return toordinal(dt)
end

"""
`chkdatetime(v...)` use `try ... catch ...` to check if a vector `[yyyy, mm, dd, hh, MM, ss]` is a valid datetime. It returns `false` if it is not an legal date vector array.
"""
function chkdatetime(v...)
    dtisvalid = true
    try
        DateTime(v...)
    catch
        dtisvalid = false
    end
    return dtisvalid
end


function Statistics.mean(dt0::DateTime, dt1::DateTime)
    delT = dt1 - dt0
    meandt = dt0 + 0.5delT
    return meandt

end
