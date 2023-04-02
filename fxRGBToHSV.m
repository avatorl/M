//Convert RGB color into HSV color (return [H,S,V] record
(R as number, G as number, B as number) =>

let
    _r = R/255,
    _g = G/255,
    _b = B/255,

    cmax = List.Max({_r,_g,_b}),
    cmin = List.Min({_r,_g,_b}),
    diff = cmax - cmin,
    
    // h, s, v = hue, saturation, value
    h = if cmax = cmin then 0 else if cmax = _r then 60*((_g-_b)/diff+0) else if cmax = _g then 60*((_b-_r)/diff+2) else if cmax = _b then 60*((_r-_g)/diff+4) else -1,
    s = if cmax = 0 then 0 else (diff / cmax) * 100,
    v = cmax * 100,

    h360 = if h<0 then h+360 else h,

    Result = [H=h360,S=s,V=v]
in
    Result
