// Convert RGB color into HSV color (returns a record with [H, S, V] values)
(R as number, G as number, B as number) =>

let
    // Normalize the RGB values to a scale of 0 to 1
    _r = R / 255,
    _g = G / 255,
    _b = B / 255,

    // Calculate the maximum and minimum of the normalized RGB values
    cmax = List.Max({_r, _g, _b}),
    cmin = List.Min({_r, _g, _b}),
    diff = cmax - cmin,  // Calculate the difference between max and min, which is used to determine saturation and hue
    
    // Calculate the Hue (H)
    // Hue is determined by the dominant color (cmax) and its relation to the other colors
    h = if cmax = cmin then 
            0  // If there is no difference, hue is 0 (undefined)
        else if cmax = _r then 
            60 * ((_g - _b) / diff + 0)  // If red is the dominant color
        else if cmax = _g then 
            60 * ((_b - _r) / diff + 2)  // If green is the dominant color
        else if cmax = _b then 
            60 * ((_r - _g) / diff + 4)  // If blue is the dominant color
        else 
            -1,  // Error case (should not occur),

    // Calculate the Saturation (S)
    // Saturation is calculated based on the difference between the max and min values
    s = if cmax = 0 then 
            0  // If the max value is 0 (black), saturation is 0
        else 
            (diff / cmax) * 100,  // Otherwise, saturation is the ratio of the difference to the max, scaled to 100
    
    // Calculate the Value (V)
    // Value is simply the maximum of the RGB components, scaled to 100
    v = cmax * 100,

    // Adjust hue to be within the 0-360 range
    h360 = if h < 0 then 
               h + 360  // If hue is negative, add 360 to wrap it around
           else 
               h,

    // Create the result as a record with H, S, and V values
    Result = [H = h360, S = s, V = v]
in
    Result
