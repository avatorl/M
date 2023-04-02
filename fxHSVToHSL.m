//Convert HSV color into HSL color (return [HSL_H,HSL_S,HSL_L] record)
(HSV_H as number, HSV_S as number, HSV_V as number) =>
let
    _s=HSV_S/100,
    _v=HSV_V/100,

    H =HSV_H,
    L =_v-_v*_s/2,
    S = if (L = 0 or L = 1) then 0 else (_v-L)/List.Min({L,1-L}),

    Result = [HSL_H=H,HSL_S=S*100,HSL_L=L*100]
in
    Result
