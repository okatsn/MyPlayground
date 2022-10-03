
"""
Check if the pixel is white or transparent.
"""
function iswhite(pixel::RGBA)
    pixel.alpha == 0 || _iswhite(pixel)
end

function iswhite(pixel::RGB)
    _iswhite(pixel)
end

function _iswhite(pixel)
    (pixel.r ==1 && pixel.g ==1 &&pixel.b ==1)
end

"""
Given the file path `filei`, `cropwhite(filei::AbstractString; padding_w = 0.5, padding_h = 0.2, saveInplace=false)`
returns the cropped image
"""
function cropwhite(filei::AbstractString; padding_w = 0.5, padding_h = 0.2, saveInplace=false)
    cpad_h = 1-padding_h
    cpad_w = 1-padding_w

    pngi = Images.load(filei)

    hmax, wmax = size(pngi)

    M_iswhite = iswhite.(pngi)

    notwhite_w = .!all(M_iswhite, dims=1) |> vec
    notwhite_h = .!all(M_iswhite, dims=2) |> vec # convert N by 1 or 1 by N Matrix to Vector

    w0, w1 = map(f -> f(notwhite_w), (findfirst, findlast))
    h0, h1 = map(f -> f(notwhite_h), (findfirst, findlast))

    w0e, w1e = _extend(w0, w1, wmax, cpad_w)
    h0e, h1e = _extend(h0, h1, hmax, cpad_h)

    imgc = pngi[h0e:h1e, w0e:w1e]
    if saveInplace
        Images.save(filei, imgc)
    end
    return imgc
end

"""
Given the indices `w0`, `w1` indicating the left- and right- non-white boundary of the image, returns the extended indices `w0e` and `w1e` by factor `cpad_w`.
"""
function _extend(w0, w1,  wmax, cpad_w)
    wmin = 1
    w0e = maximum([round(w0*cpad_w), wmin]) |> Int
    w1e = minimum([w1+w0-w0e, wmax]) |> Int
    return w0e, w1e
end
