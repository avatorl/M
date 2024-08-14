// Convert HSV (Hue, Saturation, Value) color into HSL (Hue, Saturation, Lightness) color
//returns a record with [HSL_H, HSL_S, HSL_L] values
(HSV_H as number, HSV_S as number, HSV_V as number) =>
let
    // Normalize the Saturation (S) and Value (V) from the HSV model to a 0-1 scale
    _s = HSV_S / 100,
    _v = HSV_V / 100,

    // Hue remains the same in both HSV and HSL models
    H = HSV_H,

    // Calculate the Lightness (L)
    // Lightness is calculated by taking the value and adjusting it based on the saturation
    L = _v - (_v * _s / 2),

    // Calculate the new Saturation (S) for the HSL model
    // Saturation in HSL is adjusted based on Lightness
    S = if (L = 0 or L = 1) then 
            0  // If Lightness is 0 (black) or 1 (white), Saturation is 0
        else 
            (_v - L) / List.Min({L, 1 - L}),  // Otherwise, it's based on the ratio of Value and Lightness

    // Create the result as a record with HSL_H, HSL_S, and HSL_L values
    Result = [HSL_H = H, HSL_S = S * 100, HSL_L = L * 100]
in
    Result
