#Requires AutoHotKey v2.0

/**
 *  Color.ahk
 *
 *  @version 1.4
 *  @author Komrad Toast (komrad.toast@hotmail.com)
 *  @see https://www.autohotkey.com/boards/viewtopic.php?f=83&t=132433
 *  @license MIT
 *
 *  Copyright (c) 2024 Tyler J. Colby (Komrad Toast)
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 *  documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
 *  and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 *  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 *  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
**/

/**
 * Color class. Stores a decimal RGB color representation.
 * ___
 * @constructor ```Color(colorArgs*)```
 * ___
 * @param colorArgs - Color arguments to initialize the color from.
 * - Can be RGB, Hex, or Color Name.
 * - Hex is in the format `RGB`, `ARGB`, `RRGGBB` or `AARRGGBB`. `0x` and `#` are optional.
 * - RGB is in the format `R, G, B` or `R, G, B, A`.
 * - Color Name can be any of the standard AHK color names.
 * ___
 * @example
 * Color("Fuschia")        ; AutoHotKey color names
 * Color("#27D")           ; #RGB
 * Color("#27DF")          ; #ARGB
 * Color("#2277DD")        ; #RRGGBB
 * Color("#2277DDFF")      ; #AARRGGBB
 * Color(22, 77, 221)      ; R, G, B
 * Color(22, 77, 221, 255) ; R, G, B, A
**/
class Color
{
    R: i32
    G: i32
    B: i32
    A: i32

    /** @property {String} HexFormat The hexadecimal color code format for `Color.ToHex().Full` (e.g. `#{R}{G}{B}{A}`). */
    HexFormat
    {
        get
        {
            hex := this._hexFormat
            hex := RegExReplace(hex, "{4:02X}", "{A}")
            hex := RegExReplace(hex, "{1:02X}", "{R}")
            hex := RegExReplace(hex, "{2:02X}", "{G}")
            hex := RegExReplace(hex, "{3:02X}", "{B}")
            return hex
        }

        set
        {
            value := RegExReplace(value, "im){A}", "{4:02X}")
            value := RegExReplace(value, "im){R}", "{1:02X}")
            value := RegExReplace(value, "im){G}", "{2:02X}")
            value := RegExReplace(value, "im){B}", "{3:02X}")
            this._hexFormat := value
        }
    }

    /** @property {String} RGBFormat The RGB color code format for `Color.ToRGB().Full` (e.g. `RGBA({R},{G},{B},{A})`). */
    RGBFormat
    {
        get
        {
            rgb := this._rgbFormat
            rgb := RegExReplace(rgb, "{1:d}", "{R}")
            rgb := RegExReplace(rgb, "{2:d}", "{G}")
            rgb := RegExReplace(rgb, "{3:d}", "{B}")
            rgb := RegExReplace(rgb, "{4:d}", "{A}")
            return rgb
        }
        set
        {
            value := RegExReplace(value, "im){R}", "{1:d}")
            value := RegExReplace(value, "im){G}", "{2:d}")
            value := RegExReplace(value, "im){B}", "{3:d}")
            value := RegExReplace(value, "im){A}", "{4:d}")
            this._rgbFormat := value
            this.Full := Format(this._rgbFormat, this.R, this.G, this.B, this.A)
        }
    }

    /** @property {String} HSLFormat The HSL color code format for `Color.ToHSL().Full` (e.g. `hsl({H},{S}%,{L}%)`). */
    HSLFormat
    {
        get
        {
            hsl := this._hslFormat
            hsl := RegExReplace(hsl, "{1:d}", "{H}")
            hsl := RegExReplace(hsl, "{2:d}", "{S}")
            hsl := RegExReplace(hsl, "{3:d}", "{L}")
            hsl := RegExReplace(hsl, "{4:d}", "{A}")
            return hsl
        }

        set
        {
            value := RegExReplace(value, "im){H}", "{1:d}")
            value := RegExReplace(value, "im){S}", "{2:d}")
            value := RegExReplace(value, "im){L}", "{3:d}")
            value := RegExReplace(value, "im){A}", "{4:d}")
            this._hslFormat := value
        }
    }

    /** @property {String} HWBFormat The HWB color code format for `Color.ToHWB().Full` (e.g. `hwb({H},{W}%,{B}%)`). */
    HWBFormat
    {
        get
        {
            hwb := this._hwbFormat
            hwb := RegExReplace(hwb, "{1:d}", "{H}")
            hwb := RegExReplace(hwb, "{2:d}", "{W}")
            hwb := RegExReplace(hwb, "{3:d}", "{B}")
            return hwb
        }

        set
        {
            value := RegExReplace(value, "im){H}", "{1:d}")
            value := RegExReplace(value, "im){W}", "{2:d}")
            value := RegExReplace(value, "im){B}", "{3:d}")
            this._hwbFormat := value
        }
    }

    /** @property {String} CMYKFormat The CMYK color code format for `Color.ToCMYK().Full` (e.g. `cmyk({C}%,{M}%,{Y}%,{K}%)`). */
    CMYKFormat
    {
        get
        {
            cmyk := this._cmykFormat
            cmyk := RegExReplace(cmyk, "{1:d}", "{C}")
            cmyk := RegExReplace(cmyk, "{2:d}", "{M}")
            cmyk := RegExReplace(cmyk, "{3:d}", "{Y}")
            cmyk := RegExReplace(cmyk, "{4:d}", "{K}")
            return cmyk
        }

        set
        {
            value := RegExReplace(value, "im){C}", "{1:d}")
            value := RegExReplace(value, "im){M}", "{2:d}")
            value := RegExReplace(value, "im){Y}", "{3:d}")
            value := RegExReplace(value, "im){K}", "{4:d}")
            this._cmykFormat := value
        }
    }

    /** @property {String} NColFormat The NCol color code format for `Color.ToNCol().Full` (e.g. `ncol({H},{W}%,{B}%)`). */
    NColFormat
    {
        get
        {
            ncol := this._nColFormat
            ncol := RegExReplace(ncol, "{1:d}", "{H}")
            ncol := RegExReplace(ncol, "{2:d}", "{W}")
            ncol := RegExReplace(ncol, "{3:d}", "{B}")
            return ncol
        }

        set
        {
            value := RegExReplace(value, "im){H}", "{1:s}")
            value := RegExReplace(value, "im){W}", "{2:d}")
            value := RegExReplace(value, "im){B}", "{3:d}")
            this._nColFormat := value
        }
    }

    /** @property {String} XYZFormat The XYZ color code format for `Color.ToXYZ().Full` (e.g. `xyz({X},{Y},{Z})`).
     * To change the amount of decimal places, just add it after the channel: `{X:2}` would round the `X` Channel to 2 decimal places.
     */
    XYZFormat
    {
        get
        {
            xyz := this._xyzFormat
            xyz := RegExReplace(xyz, "{1(:0.[0-9]+f)?}", "{X}")
            xyz := RegExReplace(xyz, "{2(:0.[0-9]+f)?}", "{Y}")
            xyz := RegExReplace(xyz, "{3(:0.[0-9]+f)?}", "{Z}")
            return xyz
        }

        set
        {
            value := RegExReplace(value, "im){X:(\d+)}", "{1:0.$1f}")
            value := RegExReplace(value, "im){Y:(\d+)}", "{2:0.$1f}")
            value := RegExReplace(value, "im){Z:(\d+)}", "{3:0.$1f}")
            value := RegExReplace(value, "im){X}", "{1:f}")
            value := RegExReplace(value, "im){Y}", "{2:f}")
            value := RegExReplace(value, "im){Z}", "{3:f}")
            this._xyzFormat := value
        }
    }

    /** @property {String} LabFormat The Lab color code format for `Color.ToLab().Full` (e.g. `lab({L},{a},{b})`).
     * To change the amount of decimal places, just add it after the channel: `{L:2}` would round the `L` Channel to 2 decimal places.
     */
    LabFormat
    {
        get
        {
            lab := this._labFormat
            lab := RegExReplace(lab, "{1(:0.[0-9]+f)?}", "{L}")
            lab := RegExReplace(lab, "{2(:0.[0-9]+f)?}", "{a}")
            lab := RegExReplace(lab, "{3(:0.[0-9]+f)?}", "{b}")
            return lab
        }

        set
        {
            value := RegExReplace(value, "im){L:(\d+)}", "{1:0.$1f}")
            value := RegExReplace(value, "im){A:(\d+)}", "{2:0.$1f}")
            value := RegExReplace(value, "im){B:(\d+)}", "{3:0.$1f}")
            value := RegExReplace(value, "im){L}", "{1:f}")
            value := RegExReplace(value, "im){A}", "{2:f}")
            value := RegExReplace(value, "im){B}", "{3:f}")
            this._labFormat := value
        }
    }

    /** @property {String} YIQFormat The Lab color code format for `Color.ToLab().Full` (e.g. `lab({L},{a},{b})`).
     * To change the amount of decimal places, just add it after the channel: `{Y:2}` would round the `Y` Channel to 2 decimal places.
     */
    YIQFormat
    {
        get
        {
            yiq := this._yiqFormat
            yiq := RegExReplace(yiq, "{1(:0.[0-9]+f)?}", "{Y}")
            yiq := RegExReplace(yiq, "{2(:0.[0-9]+f)?}", "{I}")
            yiq := RegExReplace(yiq, "{3(:0.[0-9]+f)?}", "{Q}")
            return yiq
        }

        set
        {
            value := RegExReplace(value, "im){Y:(\d+)}", "{1:0.$1f}")
            value := RegExReplace(value, "im){I:(\d+)}", "{2:0.$1f}")
            value := RegExReplace(value, "im){Q:(\d+)}", "{3:0.$1f}")
            value := RegExReplace(value, "im){Y}", "{1:f}")
            value := RegExReplace(value, "im){I}", "{2:f}")
            value := RegExReplace(value, "im){Q}", "{3:f}")
            this._yiqFormat := value
        }
    }

    ; Default Format Strings
    _hexFormat  := "0x{1:02X}{2:02X}{3:02X}"
    _rgbFormat  := "rgba({1:d}, {2:d}, {3:d}, {4:d})"
    _hslFormat  := "hsl({1:d}, {2:d}%, {3:d}%)"
    _hwbFormat  := "hwb({1:d}, {2:d}%, {3:d}%)"
    _cmykFormat := "cmyk({1:d}%, {2:d}%, {3:d}%, {4:d}%)"
    _nColFormat := "ncol({1:s}, {2:d}%, {3:d}%)"
    _xyzFormat  := "xyz({1:0.2f}, {2:0.2f}, {3:0.2f})"
    _labFormat  := "lab({1:0.2f}, {2:0.2f}, {3:0.2f})"
    _yiqFormat  := "yiq({1:0.2f}, {2:0.2f}, {3:0.2f})"

    static Black       => Color("Black")
    static Silver      => Color("Silver")
    static Gray        => Color("Gray")
    static White       => Color("White")
    static Maroon      => Color("Maroon")
    static Red         => Color("Red")
    static Purple      => Color("Purple")
    static Fuchsia     => Color("Fuchsia")
    static Green       => Color("Green")
    static Lime        => Color("Lime")
    static Olive       => Color("Olive")
    static Yellow      => Color("Yellow")
    static Navy        => Color("Navy")
    static Blue        => Color("Blue")
    static Teal        => Color("Teal")
    static Aqua        => Color("Aqua")
    static Transparent => Color("Transparent")

    /**
     * @constructor Creates a new `Color` instance from the given color arguments
     * ___
     * @param colorArgs - Color arguments to initialize the color from.
     * - Can be RGB, Hex, or Color Name.
     * - Hex is in the format `RGB`, `ARGB`, `RRGGBB` or `AARRGGBB`. `0x` and `#` are optional.
     * - RGB is in the format `R, G, B` or `R, G, B, A`.
     * - Color Name can be any of the standard AHK color names.
     * ___
     * @example
     * Color("Fuschia")        ; AutoHotKey color names
     * Color("#27D")           ; #RGB
     * Color("#27DF")          ; #ARGB
     * Color("#2277DD")        ; #RRGGBB
     * Color("#2277DDFF")      ; #AARRGGBB
     * Color(22, 77, 221)      ; R, G, B
     * Color(22, 77, 221, 255) ; R, G, B, A
     */
    __New(colorArgs*)
    {
        colorNames := Map(
            "Black" , "FF000000", "Silver", "FFC0C0C0", "Gray"  , "FF808080", "White"  , "FFFFFFFF",
            "Maroon", "FF800000", "Red"   , "FFFF0000", "Purple", "FF800080", "Fuchsia", "FFFF00FF",
            "Green" , "FF008000", "Lime"  , "FF00FF00", "Olive" , "FF808000", "Yellow" , "FFFFFF00",
            "Navy"  , "FF000080", "Blue"  , "FF0000FF", "Teal"  , "FF008080", "Aqua"   , "FF00FFFF",
        )

        colorNames.Set("Transparent", "00000000")

        switch colorArgs.Length
        {
            case 0:
                this.R := 0
                this.G := 0
                this.B := 0
                this.A := 255
            case 1:
                hex := colorArgs[1]
                if (colorNames.Has(hex))
                    hex := colorNames[hex]

                col := Color.FromHex(hex)
                this.R := col.R
                this.G := col.G
                this.B := col.B
                this.A := col.A
            case 3, 4:
                col := Color.FromRGB(colorArgs[1], colorArgs[2], colorArgs[3], colorArgs.Length == 4 ? colorArgs[4] : 255)
                this.R := col.R
                this.G := col.G
                this.B := col.B
                this.A := col.A
            default:
                throw Error("Invalid Color arguments")
        }

        this.Full := Format(this._rgbFormat, this.R, this.G, this.B, this.A)
    }

    /**
     * Checks if this color is equal to another color.
     * ___
     * @returns {Boolean}
     */
    IsEqual(col) => this.ToInt() == col.ToInt()

    /**
    * Converts the Color object to its integer representation.
    * The integer includes all four channels: Alpha, Red, Green, and Blue.
    * ___
    * @returns {Integer}
    */
    ToInt(mode := 1)
    {
        switch mode
        {
            case 1: ; GDI+ ARGB Format
                return (this.A << 24) | (this.R << 16) | (this.G << 8) | this.B
            case 2: ; GDI BGR Format
                return (this.B << 16) | (this.G << 8) | this.R
            case 3: ; AHK "+Background" format
                return this.ToHex("{R}{G}{B}").Full
        }
    }

    /**
     * Converts the stored color to Hexadecimal representation.
     * ___
     * @param {String} formatString The string used to format the output.
     * ___
     * @returns {Object} `{R:(00-FF), G:(00-FF), B:(00-FF), A:(00-FF), Full:string}`
     */
    ToHex(formatString := "")
    {
        if formatString
        {
            oldFormat := this.HexFormat
            this.HexFormat := formatString
        }

        full := Format(this._hexFormat, this.R, this.G, this.B, this.A)

        if formatString
            this.HexFormat := oldFormat

        return {
            R: Format("{:02X}", this.R),
            G: Format("{:02X}", this.G),
            B: Format("{:02X}", this.B),
            A: Format("{:02X}", this.A),
            Full: full
        }
    }

    /**
     * Converts the stored color to HSLA representation.
     * ___
     * @param {String} formatString The string used to format the output.
     * ___
     * @returns {Object} `{H:(0-360), S:(0-100), L:(0-100), A:(0-1), Full:string}`
     */
    ToHSL(formatString := "")
    {
        if formatString
        {
                oldFormat := this.HSLFormat
                this.HSLFormat := formatString
        }

        r := this.R / 255
        g := this.G / 255
        b := this.B / 255
        a := this.A / 255

        cmax := Max(r, g, b)
        cmin := Min(r, g, b)
        delta := cmax - cmin

        l := (cmax + cmin) / 2

        if (delta == 0)
        {
            h := 0
            s := 0
        }
        else
        {
            s := delta / (1 - Abs(2 * l - 1))

            if (cmax == r)
                h := 60 * Mod((g - b) / delta, 6)
            else if (cmax == g)
                h := 60 * ((b - r) / delta + 2)
            else
                h := 60 * ((r - g) / delta + 4)

            if (h < 0)
                h += 360
        }

        full := Format(this._hslFormat, Round(h), Round(s * 100), Round(l * 100))

        if formatString
            this.HSLFormat := oldFormat

        return {
            H: Round(h),
            S: Round(s * 100),
            L: Round(l * 100),
            A: Round(a, 1),
            Full: full
        }
    }

    /**
     * Converts the stored color to HWB representation.
     * ___
     * @param {String} formatString The string used to format the `Full` output.
     * ___
     * @returns {Object} `{H:(0-360), W:(0-100), B:(0-100), Full:string}`
     */
    ToHWB(formatString := "")
    {
        if formatString
        {
            oldFormat := this.HWBFormat
            this.HWBFormat := formatString
        }

        r := this.R / 255
        g := this.G / 255
        b := this.B / 255

        cmax := Max(r, g, b)
        cmin := Min(r, g, b)
        delta := cmax - cmin

        if (delta == 0)
            h := 0
        else if (cmax == r)
            h := 60 * Mod((g - b) / delta, 6)
        else if (cmax == g)
            h := 60 * ((b - r) / delta + 2)
        else
            h := 60 * ((r - g) / delta + 4)

        if (h < 0)
            h += 360

        w := cmin
        bl := 1 - cmax

        full := Format(this._hwbFormat, Round(h), Round(w * 100), Round(bl * 100))

        if formatString
            this.HWBFormat := oldFormat

        return {
            H: Round(h),
            W: Round(w * 100),
            B: Round(bl * 100),
            Full: full
        }
    }

    /**
     * Converts the stored color to CMYK representation.
     * ___
     * @param {String} formatString The string used to format the output.
     * ___
     * @returns {Object} `{C:(0-100), M:(0-100), Y:(0-100), K:(0-100), Full:string}`
     */
    ToCMYK(formatString := "")
    {
        if formatString
        {
            oldFormat := this.CMYKFormat
            this.CMYKFormat := formatString
        }

        r := this.R / 255
        g := this.G / 255
        b := this.B / 255

        k := 1 - Max(r, g, b)

        if (k == 1)
        {
            c := 0
            m := 0
            y := 0
        }
        else
        {
            c := (1 - r - k) / (1 - k)
            m := (1 - g - k) / (1 - k)
            y := (1 - b - k) / (1 - k)
        }

        full := Format(this._cmykFormat, Round(c * 100), Round(m * 100), Round(y * 100), Round(k * 100))

        if formatString
            this.CMYKFormat := oldFormat

        return {
            C: Round(c * 100),
            M: Round(m * 100),
            Y: Round(y * 100),
            K: Round(k * 100),
            Full: full
        }
    }

    /**
     * Converts the stored color to NCol representation.
     * ___
     * @param {String} formatString The string used to format the output.
     * ___
     * @returns {Object} `{"H":string, "W":(0-100), "B":(0-100), "Full":string}`
     */
    ToNCol(formatString := "")
    {
        if formatString
        {
            oldFormat := this.NColFormat
            this.NColFormat := formatString
        }

        hwb := this.ToHWB()
        h := hwb.H
        w := hwb.W
        b := hwb.B

        hueNames := ["R", "Y", "G", "C", "B", "M"]
        hueIndex := Floor(h / 60)
        huePercent := Round(Mod(h, 60) / 60 * 100)

        ncolHue := hueNames[Mod(hueIndex, 6) + 1] . huePercent

        full := Format(this._nColFormat, ncolHue, w, b)

        if formatString
            this.NColFormat := oldFormat

        return {
            H: ncolHue,
            W: w,
            B: b,
            Full: full
        }
    }

    /**
     * Converts the stored color to XYZ representation.
     * ___
     * @param {String} formatString The string used to format the output.
     * ___
     * @returns {Object} `{"X":(0-100), "Y":(0-100), "Z":(0-100), "Full":string}`
     * ___
     * @credit Iseahound
     */
    ToXYZ(formatString := "")
    {
        if formatString
        {
            oldFormat := this.XYZFormat
            this.XYZFormat := formatString
        }

        RGB := Map(0, this.R,
                   1, this.G,
                   2, this.B)

        for i, C in RGB
        {
            C := C / 255
            RGB[i] := (C > 0.04045) ? (((C + 0.055) / 1.055)**2.4) : (C / 12.92)
        }

        x    := 100 * (0.4124564*RGB[0] + 0.3575761*RGB[1] + 0.1804375*RGB[2])
        y    := 100 * (0.2126729*RGB[0] + 0.7151522*RGB[1] + 0.0721750*RGB[2])
        z    := 100 * (0.0193339*RGB[0] + 0.1191920*RGB[1] + 0.9503041*RGB[2])
        full := Format(this._xyzFormat, x, y, z)

        if formatString
            this.XYZFormat := oldFormat

        return {
            X: x,
            Y: y,
            Z: z,
            Full: full
        }
    }

    /**
     * Converts the stored color to Lab representation.
     * ___
     * @param {String} formatString The string used to format the output.
     * ___
     * @returns {Object} `{"L":(0 - 100), "a":(-100 - +100), "b":(-100 - +100), "Full":string}`
     * ___
     * @credit Iseahound
     */
    ToLab(formatString := "")
    {
        if formatString
        {
            oldFormat := this.LabFormat
            this.LabFormat := formatString
        }

        _xyz := this.ToXYZ()
        XYZ := Map(0, _xyz.X,
                   1, _xyz.Y,
                   2, _xyz.Z)

        D65 := Map(0, 95.047,
                   1, 100.000, ;Reference white, 6500K, Blue Sky at Noon
                   2, 108.883)

        e := (6/29)**3
        k := (24389/27)

        for i, c in XYZ
            XYZ[i] := XYZ[i] / D65[i] ;Find Relative Color values based on D65

        for i, c in XYZ
            XYZ[i] := (c > e) ? (c**(1/3)) : (((k * c) + 16) / 116) ;Lab Function, no anonymous functions :(

        l := 116 *  XYZ[1] - 16
        a := 500 * (XYZ[0] - XYZ[1])
        b := 200 * (XYZ[1] - XYZ[2])
        full := Format(this._labFormat, l, a, b)

        if formatString
            this.LabFormat := oldFormat

        return {
            L: l,
            a: a,
            b: b,
            Full: full
        }
    }

    /**
     * Converts the stored color to YIQ representation.
     * ___
     * @param {String} formatString The string used to format the output.
     * ___
     * @returns {Object}
     * ```
     * {
     *     "Y":(0 to 1),
     *     "I":(-0.5957 to +0.5957),
     *     "Q":(-0.5226 to +0.5226),
     *     "Full":string}
     * }
     * ```
     */
    ToYIQ(formatString := "")
    {
        if formatString
        {
            oldFormat := this.LabFormat
            this.LabFormat := formatString
        }

        r := this.R / 255
        g := this.G / 255
        b := this.B / 255

        y := 0.299 * r + 0.587 * g + 0.114 * b
        i := 0.596 * r - 0.275 * g - 0.321 * b
        q := 0.212 * r - 0.523 * g + 0.311 * b
        full := Format(this._yiqFormat, y, i, q)

        if formatString
            this.YIQFormat := oldFormat

        return {
            Y: y,
            I: i,
            Q: q,
            Full: full
        }
    }

    /**
     * Generates a random color.
     * ___
     * @returns {Color}
     */
    static Random() => Color(Random(255), Random(255), Random(255))

    /**
     * Syntactic Sugar for the Color Constructor. Makes a new color using RGB or RGBA representation.
     * ___
     * @returns {Color}
     */
    static FromRGB(r, g, b, a := 255)
    {
        col := Color()
        col.R := Clamp(r, 0, 255)
        col.G := Clamp(g, 0, 255)
        col.B := Clamp(b, 0, 255)
        col.A := Clamp(a, 0, 255)
        return col

        Clamp(val, low, high) => Min(Max(val, low), high)
    }

    /**
     * Syntactic Sugar for the Color Constructor. Makes a new color using Hex RGB or ARGB representation.
     * ___
     * @returns {Color}
     */
    static FromHex(hex)
    {
        hex := RegExReplace(hex, "^(#|0x)", "")

        switch StrLen(hex)
        {
            case 3:
                R := Integer("0x" . SubStr(hex, 1, 1))
                G := Integer("0x" . SubStr(hex, 2, 1))
                B := Integer("0x" . SubStr(hex, 3, 1))
                A := 255
            case 4:
                R := Integer("0x" . SubStr(hex, 2, 1))
                G := Integer("0x" . SubStr(hex, 3, 1))
                B := Integer("0x" . SubStr(hex, 4, 1))
                A := Integer("0x" . SubStr(hex, 1, 1))
            case 6:
                R := Integer("0x" . SubStr(hex, 1, 2))
                G := Integer("0x" . SubStr(hex, 3, 2))
                B := Integer("0x" . SubStr(hex, 5, 2))
                A := 255
            case 8:
                R := Integer("0x" . SubStr(hex, 3, 2))
                G := Integer("0x" . SubStr(hex, 5, 2))
                B := Integer("0x" . SubStr(hex, 7, 2))
                A := Integer("0x" . SubStr(hex, 1, 2))
            default:
                throw Error("Invalid Hex Color length")
        }

        return Color(R, G, B, A)
    }

    /**
     * Creates a `Color` instance from HSL format.
     * ___
     * @param {Integer} h Hue        - `0 to 360`
     * @param {Integer} s Saturation - `0 to 100`
     * @param {Integer} l Lightness  - `0 to 100`
     * ___
     * @returns {Color}
     */
    static FromHSL(h, s, l)
    {
        h := Mod(h, 360) / 360
        s := Clamp(s, 0, 100) / 100
        l := Clamp(l, 0, 100) / 100

        if (s == 0)
        {
            r := g := b := l
        }
        else
        {
            q := l < 0.5 ? l * (1 + s) : l + s - l * s
            p := 2 * l - q
            r := HueToRGB(p, q, h + 1/3)
            g := HueToRGB(p, q, h)
            b := HueToRGB(p, q, h - 1/3)
        }

        return Color(Round(r * 255), Round(g * 255), Round(b * 255))

        Clamp(val, low, high) => Min(Max(val, low), high)

        HueToRGB(p, q, t)
        {
            if (t < 0)
                t += 1
            if (t > 1)
                t -= 1
            if (t < 1/6)
                return p + (q - p) * 6 * t
            if (t < 1/2)
                return q
            if (t < 2/3)
                return p + (q - p) * (2/3 - t) * 6
            return p
        }
    }

    /**
     * Creates a `Color` instance from HWB format.
     * ___
     * @param {Integer} h Hue       - `0 to 360`
     * @param {Integer} w Whiteness - `0 to 100`
     * @param {Integer} b Blackness - `0 to 100`
     * ___
     * @returns {Color}
     */
    static FromHWB(h, w, b)
    {
        h := Mod(h, 360) / 360
        w := Clamp(w, 0, 100) / 100
        b := Clamp(b, 0, 100) / 100

        if (w + b >= 1)
        {
            g := w / (w + b)
            return Color(Round(g * 255), Round(g * 255), Round(g * 255))
        }

        f := 1 - w - b
        rgb := HueToRGB(h)

        r := Round((rgb.R * f + w) * 255)
        g := Round((rgb.G * f + w) * 255)
        b := Round((rgb.B * f + w) * 255)

        return Color(r, g, b)

        Clamp(val, low, high) => Min(Max(val, low), high)

        HueToRGB(h)
        {
            h *= 6
            x := 1 - Abs(Mod(h, 2) - 1)
            switch Floor(h)
            {
                case 0: return {R: 1, G: x, B: 0}
                case 1: return {R: x, G: 1, B: 0}
                case 2: return {R: 0, G: 1, B: x}
                case 3: return {R: 0, G: x, B: 1}
                case 4: return {R: x, G: 0, B: 1}
                case 5: return {R: 1, G: 0, B: x}
            }
        }
    }

    /**
     * Creates a `Color` instance from CMYK format.
     * ___
     * @param {Integer} c Cyan        - `0 to 100`
     * @param {Integer} m Magenta     - `0 to 100`
     * @param {Integer} y Yellow      - `0 to 100`
     * @param {Integer} k Key (Black) - `0 to 100`
     * ___
     * @returns {Color}
     */
    static FromCMYK(c, m, y, k)
    {
        c := Clamp(c, 0, 100) / 100
        m := Clamp(m, 0, 100) / 100
        y := Clamp(y, 0, 100) / 100
        k := Clamp(k, 0, 100) / 100

        r := Round((1 - c) * (1 - k) * 255)
        g := Round((1 - m) * (1 - k) * 255)
        b := Round((1 - y) * (1 - k) * 255)

        return Color(r, g, b)

        Clamp(val, low, high) => Min(Max(val, low), high)
    }

    /**
     * Creates a `Color` instance from NCol format.
     * ___
     * @param {Integer} h Hue       - `(R|Y|G|C|B|M)0-100`
     * @param {Integer} w Whiteness - `0 to 100`
     * @param {Integer} b Blackness - `0 to 100`
     * ___
     * @returns {Color}
     */
    static FromNCol(h, w, b)
    {
        hueNames := "RYGCBM"
        hueIndex := InStr(hueNames, SubStr(h, 1, 1)) - 1
        huePercent := Integer(SubStr(h, 2))

        h := Mod(hueIndex * 60 + huePercent * 0.6, 360)
        w := Clamp(w, 0, 100)
        b := Clamp(b, 0, 100)

        return Color.FromHWB(h, w, b)

        Clamp(val, low, high) => Min(Max(val, low), high)
    }

    /**
     * Creates a `Color` instance from XYZ format.
     * ___
     * @param {Integer} x X Component - `0 - ~95.047`
     * @param {Integer} y Y Component - `0 - 100`
     * @param {Integer} z Z Component - `0 - ~108.883`
     * ___
     * @returns {Color}
     */
    static FromXYZ(x, y, z)
    {
        ; Normalize the inputs
        x := x / 100
        y := y / 100
        z := z / 100

        ; XYZ to RGB conversion matrix
        matrix := [
            [3.2404542, -1.5371385, -0.4985314],
            [-0.9692660, 1.8760108, 0.0415560],
            [0.0556434, -0.2040259, 1.0572252]
        ]

        ; Apply the matrix transformation
        r := x * matrix[1][1] + y * matrix[1][2] + z * matrix[1][3]
        G := x * matrix[2][1] + y * matrix[2][2] + z * matrix[2][3]
        B := x * matrix[3][1] + y * matrix[3][2] + z * matrix[3][3]

        ; Apply gamma correction
        r := (r > 0.0031308) ? (1.055 * (r ** (1/2.4)) - 0.055) : 12.92 * r
        G := (G > 0.0031308) ? (1.055 * (G ** (1/2.4)) - 0.055) : 12.92 * G
        B := (B > 0.0031308) ? (1.055 * (B ** (1/2.4)) - 0.055) : 12.92 * B

        ; Clamp values to [0, 1] range
        r := Max(0, Min(1, r))
        G := Max(0, Min(1, G))
        B := Max(0, Min(1, B))

        ; Convert to 8-bit color values
        r := Round(r * 255)
        G := Round(G * 255)
        B := Round(B * 255)

        ; Create and return a new Color object
        return Color(r, G, B)
    }

    /**
     * Creates a `Color` instance from Lab format.
     * ___
     * @param {Number} L - Lightness component (0 to 100)
     * @param {Number} a - a component (-100 to +100)
     * @param {Number} b - b component (-100 to +100)
     * ___
     * @returns {Color}
     */
    static FromLab(L, a, b)
    {
        ; Lab to XYZ conversion
        fy := (L + 16) / 116
        fx := a / 500 + fy
        fz := fy - b / 200

        ; Reference white point (D65)
        Xn := 95.047
        Yn := 100.0
        Zn := 108.883

        X := Xn * (fx > 0.206893034 ? fx * fx * fx : (fx - 16 / 116) / 7.787)
        Y := Yn * (fy > 0.206893034 ? fy * fy * fy : (fy - 16 / 116) / 7.787)
        Z := Zn * (fz > 0.206893034 ? fz * fz * fz : (fz - 16 / 116) / 7.787)

        ; Use the existing FromXYZ method to convert to RGB
        return Color.FromXYZ(X, Y, Z)
    }

    /**
     * Creates a `Color` instance from YIQ format.
     * ___
     * @param {Number} Y - Luma component (0 to 1)
     * @param {Number} I - Red-Cyan contrast (-0.5957 to +0.5957)
     * @param {Number} b - Magenta-Green contrast (-0.5226 to +0.5226)
     * ___
     * @returns {Color}
     */
    static FromYIQ(y, i, q)
    {
        r := y + 0.956 * i + 0.619 * q
        g := y - 0.272 * i - 0.647 * q
        b := y - 1.106 * i + 1.703 * q

        r := Round(Max(0, Min(r * 255, 255)))
        g := Round(Max(0, Min(g * 255, 255)))
        b := Round(Max(0, Min(b * 255, 255)))

        return Color(r, g, b)
    }

    /**
     * Creates a `Color` instance from a temperaure
     * ___
     * @param {Number} temp The color temperature in Kelvin
     * ___
     * @returns {Color}
     */
    static FromTemp(temp, tint := 0)
    {
        temp := temp / 100
        if (temp <= 66)
            r := 255
        else
            r := Max(0, Min(255, 329.698727446 * ((temp - 60) ** -0.1332047592)))

        ; Calculate Green
        if (temp <= 66)
            g := 99.4708025861 * Ln(temp) - 161.1195681661
        else
            g := 288.1221695283 * ((temp - 60) ** -0.0755148492)
        g := Max(0, Min(255, g))

        ; Calculate Blue
        if (temp >= 66)
            b := 255
        else if (temp <= 19)
            b := 0
        else
            b := Max(0, Min(255, 138.5177312231 * Ln(temp - 10) - 305.0447927307))

        ; Apply tint
        if (tint > 0)
        {
            g := Min(g + tint, 255)
        }
        else if (tint < 0)
        {
            m := Min(r - tint, Min(b - tint, 255))
            r := r + m
            b := b + m
        }

        return Color(r, g, b)
    }

    /**
     * Creates a new `Color` by calculating the average of two or more colors.
     * ___
     * @param {Color...} colors The colors to calculate the average of.
     * ___
     * @returns {Color}
     */
    static Average(colors*)
    {
        if (colors[1] is ColorArray) or (colors[1] is Array)
            colors := colors[1]

        r := 0
        g := 0
        b := 0

        for _color in colors
        {
            r += _color.R
            g += _color.G
            b += _color.B
        }

        count := colors.Length
        return Color(Round(r / count), Round(g / count), Round(b / count))
    }

    /**
     * Creates a new `Color` by multiplying two or more colors.
     * ___
     * @param colors The colors to multiply.
     * ___
     * @returns {Color}
     */
    static Multiply(colors*)
    {
        if (colors[1] is ColorArray) or (colors[1] is Array)
            colors := colors[1]

        r := 1
        g := 1
        b := 1

        for _color in colors
        {
            r *= _color.R / 255
            g *= _color.G / 255
            b *= _color.B / 255
        }

        return Color(Round(r * 255), Round(g * 255), Round(b * 255))
    }

    /**
     * Inverts the current color and returns it as a new `Color` instance.
     * ___
     * @returns {Color}
     */
    Invert() => Color(255 - this.R, 255 - this.G, 255 - this.B, this.A)

    /**
     * Returns the Rec. 601 grayscale representation of the current color.
     * ___
     * @returns {Color}
     *
     * ___
     * @credit Iseahound
     */
    Grayscale()
    {
        sRGB := this.ToHex("0x{R}{G}{B}").Full
        static rY := 0.212655
        static gY := 0.715158
        static bY := 0.072187

        c1 := 255 & ( sRGB >> 16 )
        c2 := 255 & ( sRGB >> 8 )
        c3 := 255 & ( sRGB )

        Loop 3 {
           c%A_Index% := c%A_Index% / 255
           c%A_Index% := (c%A_Index% <= 0.04045) ? c%A_Index% / 12.92 : ((c%A_Index% + 0.055) / (1.055) ) ** 2.4
        }

        v := rY*c1 + gY*c2 + bY*c3
        v := (v <= 0.0031308) ? v * 12.92 : 1.055 * (v ** (1.0/2.4)) - 0.055
        g := Round(v*255)
        return Color(g, g, g)
    }

    /**
    * Applies a sepia filter to the current color.
    * The sepia effect is achieved by adjusting the RGB values using specific coefficients.
    * ___
    * @returns {Color} A new Color object with the sepia filter applied.
    */
    Sepia()
    {
        r := this.R
        g := this.G
        b := this.B

        newR := Min(Round((r * 0.393) + (g * 0.769) + (b * 0.189)), 255)
        newG := Min(Round((r * 0.349) + (g * 0.686) + (b * 0.168)), 255)
        newB := Min(Round((r * 0.272) + (g * 0.534) + (b * 0.131)), 255)

        return Color(newR, newG, newB)
    }

    /**
     * Shifts the current color's hue by the specified amount of degrees.
     * ___
     * @param {Integer} degrees The amount to shift the hue by - `0 to 360`.
     * ___
     * @returns {Color}
     */
    ShiftHue(degrees)
    {
        hsl := this.ToHSL()
        newHue := Mod(hsl.H + degrees, 360)
        return Color.FromHSL(newHue, hsl.S, hsl.L)
    }

    /**
     * Shifts the current color's saturation by the specified amount.
     * ___
     * @param {Integer} degrees The amount to shift the saturation by - `0 to 100`.
     * ___
     * @returns {Color}
     */
    ShiftSaturation(amount)
    {
        hsl := this.ToHSL()
        newSaturation := Max(0, Min(100, hsl.S + amount))
        return Color.FromHSL(hsl.H, newSaturation, hsl.L)
    }

    /**
     * Increases the current color's saturation by the specified amount. Negative values are made positive.
     * ___
     * @param {Integer} percentage The amount to increase the saturation by - `0 to 100`.
     * ___
     * @returns {Color}
     */
    Saturate(percentage)   => this.ShiftSaturation( Abs(percentage))

    /**
     * Decreases the current color's saturation by the specified amount. Positive values are made negative.
     * ___
     * @param {Integer} percentage The amount to decrease the saturation by - `0 to 100`.
     * ___
     * @returns {Color}
     */
    Desaturate(percentage) => this.ShiftSaturation(-Abs(percentage))

    /**
     * Shifts the current color's lightness by the specified amount.
     * ___
     * @param {Integer} degrees The amount to shift the lightness by - `0 to 100`.
     * ___
     * @returns {Color}
     */
    ShiftLightness(amount)
    {
        hsl := this.ToHSL()
        newLightness := Max(0, Min(100, hsl.L + amount))
        return Color.FromHSL(hsl.H, hsl.S, newLightness)
    }

    /**
     * Increases the current color's lightness by the specified amount. Negative values are made positive.
     * ___
     * @param {Integer} percentage The amount to increase the lightness by - `0 to 100`.
     * ___
     * @returns {Color}
     */
    Lighten(percentage) => this.ShiftLightness( Abs(percentage))

    /**
     * Decreases the current color's lightness by the specified amount. Positive values are made negative.
     * ___
     * @param {Integer} percentage The amount to decrease the lightness by - `0 to 100`.
     * ___
     * @returns {Color}
     */
    Darken(percentage)  => this.ShiftLightness(-Abs(percentage))

    /**
     * Shifts the current color's whiteness by the specified amount.
     * ___
     * @param {Integer} degrees The amount to shift the whiteness by - `0 to 100`.
     * ___
     * @returns {Color}
     */
    ShiftWhiteness(amount)
    {
        hwb := this.ToHWB()
        newWhiteness := Max(0, Min(100, hwb.W + amount))
        return Color.FromHWB(hwb.H, newWhiteness, hwb.B)
    }

    /**
     * Shifts the current color's blackness by the specified amount.
     * ___
     * @param {Integer} degrees The amount to shift the blackness by - `0 to 100`.
     * ___
     * @returns {Color}
     */
    ShiftBlackness(amount)
    {
        hwb := this.ToHWB()
        newBlackness := Max(0, Min(100, hwb.B + amount))
        return Color.FromHWB(hwb.H, hwb.W, newBlackness)
    }

    /**
     * Returns the complementary color to the current `Color` instance.
     * ___
     * @returns {Color}
     */
    Complement() => this.ShiftHue(180)

    /**
     * Returns the luminance (`0 to 1`) of the current `Color` instance.
     * ___
     * @returns {Float}
     */
    GetLuminance()
    {
        r := this.R / 255
        g := this.G / 255
        b := this.B / 255
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    /**
     * Returns `True` if the current `Color` instance's Luminance is above `0.5`.
     * @returns {Boolean}
     */
    IsLight() => this.GetLuminance() > 0.5

    /**
     * Returns `True` the current `Color` instance's Luminance is equal to or below `0.5`.
     * ___
     * @returns {Boolean}
     */
    IsDark() => this.GetLuminance() <= 0.5

    /**
     * Gets the contrast ratio between the current `Color` instance and another.
     * ___
     * @param {Color} _color The `Color` instance to compare to.
     * ___
     * @returns {Float}
     */
    GetContrast(_color)
    {
        l1 := this.GetLuminance()
        l2 := _color.GetLuminance()

        if (l1 > l2)
            return (l1 + 0.05) / (l2 + 0.05)
        else
            return (l2 + 0.05) / (l1 + 0.05)
    }

    /**
     * Mixes the current `Color` instance with another and returns a new `Color`.
     * ___
     * @param {Color} _color The color to mix with.
     * @param {Integer} weight The weight used to mix the two colors.
     * ___
     * @returns {Color}
     */
    Mix(_color, weight := 50)
    {
        w := weight / 100
        r := Round(this.R * (1 - w) + _color.R * w)
        g := Round(this.G * (1 - w) + _color.G * w)
        b := Round(this.B * (1 - w) + _color.B * w)

        return Color.FromRGB(r, g, b)
    }

    /**
     * Generates a monochromatic color scheme based on the current color.
     * ___
     * @param {number} [count=5] - The number of colors to generate in the scheme.
     * @param {number} [lightnessRange=15] - The percentage difference of lightness between each color.
     * ___
     * @returns {Color[]}
     */
    Monochromatic(count := 5, lightnessRange := 15)
    {
        lightnessRange := (lightnessRange * 2) / 100
        hsl := this.ToHSL()
        minLightness := Max(10, hsl.L - lightnessRange * 50)
        maxLightness := Min(90, hsl.L + lightnessRange * 50)

        colors := ColorArray()
        step := (maxLightness - minLightness) / (count - 1)
        Loop count
        {
            l := minLightness + (A_Index - 1) * step
            newColor := Color.FromHSL(hsl.H, hsl.S, l)
            colors.Push(newColor)
        }
        return colors
    }

    /**
     * Generates `count` colors that are analogous with (next to) the current color by `angle` degrees.
     * ___
     * @param {Integer} angle The angle between the analogous colors.
     * @param {Integer} count Total colors to return (includes original).
     * ___
     * @returns {Color[]}
     */
    Analogous(angle := 30, count := 3)
    {
        hsl := this.ToHSL()
        colors := ColorArray()
        colors.Push(this)

        Loop count - 1
        {
            newH := Mod(hsl.H + angle * A_Index, 360)
            colors.Push(Color.FromHSL(newH, hsl.S, hsl.L))
        }

        return colors
    }

    /**
     * Generates a Triadic color scheme from the current color. Triadic colors are offset from the current by `120°` and `240°`.
     * ___
     * @returns {Color[3]}
     */
    Triadic() => this.Analogous(120, 3)

    /**
     * Generates a Tetradic color scheme from the current color.
     * A color is offset from the current color by `angle`°,
     * then the complements of both are retrieved.
     * ___
     * @returns {Color[4]}
     */
    Tetradic(angle := 60)
    {
        col2 := this.ShiftHue(angle)
        thisComp := this.Complement()
        col2Comp := col2.Complement()

        return ColorArray(this, col2, thisComp, col2Comp)
    }

    /** Generates a Square Color scheme, the colors are offset by 90°, 180°, and 270° from the current color */
    Square() => this.Analogous(90, 4)

    /**
     * Produces a gradient from the current `Color` instance to any number of other color instances.
     * Gradient order is defined by the order the colors are supplied in. The current Color instance
     * is always the first color.
     * ___
     * @param {Integer} [steps=10] How many steps for the ENTIRE gradient. This will be divided by the
     * number of colors to determine the number of steps between each color.
     * @param {Color...} colors The colors to interpolate between. Must be: `1 <= colors.Length <= steps`
     * ___
     * @returns {Color[]}
     */
    Gradient(steps := 10, colors*) => Color.Gradient(steps, this, colors*)

    /**
     * Produces a gradient from each `Color` instance to the next.
     * Gradient order is defined by the order the colors are supplied in.
     * ___
     * @param {Integer} [steps=10] How many steps for the ENTIRE gradient. This will be divided by the
     * number of colors to determine the number of steps between each color.
     * @param {Color...} colors The colors to interpolate between. Must be: `2 <= colors.Length <= steps`
     * ___
     * @returns {Color[]}
     */
    static Gradient(steps := 10, colors*) => Gradient(steps, colors*)
}

/**
 * ColorArray class. Stores an array of Color objects.
 * ___
 * @constructor ```ColorArray(colors*)```
 * ___
 * @param colors - Color arguments to initialize the array.
 * ___
 * @example
 * ColorArray(Color("Red"), Color.Green, Color("Blue"), Color("#0000FF"))
 */
class ColorArray extends Array
{
    /**
     * @constructor Creates a new `ColorArray` instance from the given `Color` arguments
     * ___
     * @param colorArgs - `Color` arguments to initialize the `ColorArray` from.
     * ___
     * @example
     * ColorArray(Color.Red, Color("#539A3D"), Color.FromHWB(311, 78, 65))
     */
    __New(colors*)
    {
        if (colors.Length == 1) and ((colors[1] is Array) or (colors[1] is ColorArray))
            colors := colors[1]

        for col in colors
            if col is Color
                this.Push(col)
            else
                throw ValueError("ColorArray: Argument must be a Color object", -1, col)
    }

    /**
     * Swaps Colors at indexes a and b
     * ___
     * @param a First Color index to swap
     * @param b Second Color index to swap
     * ___
     * @returns {ColorArray}
     *
     * ___
     * @credit Descolada
     */
    Swap(a, b)
    {
        temp := this[b]
        this[b] := this[a]
        this[a] := temp
        return this
    }

    /**
     * Applies a function to each element in the array (mutates the array).
     * ___
     * @param func The mapping function that accepts one argument.
     * @param arrays Additional arrays to be accepted in the mapping function
     * ___
     * @returns {ColorArray}
     *
     * ___
     * @credit Descolada
     */
    Map(_func, cArrays*)
    {
        if not (_func is Func)
            throw ValueError("Map: _func must be a function", -1)

        for i, col in this
        {
            var := _func.Bind(col?)

            for _, cArr in cArrays
                var := _func.Bind(cArr.Has(i) ? cArr[i] : unset)

            try var := var()
            this[i] := var
        }

        return this
    }

    /**
     * Applies a function to each element in the array.
     * ___
     * @param func The callback function with arguments Callback(value[, index, array]).
     * ___
     * @returns {Array}
     *
     * ___
     * @credit Descolada
     * ___
     * @example
     * ; Outputs the hex value of ever color in the ColorArray
     * colArray.ForEach((col) => OutputDebug(col.ToHex("#{R}{G}{B}").Full))
     */
    ForEach(_func)
    {
        if not (_func is Func)
            throw ValueError("ForEach: _func must be a function", -1)

        for index, col in this
            _func(col, index, this)

        return this
    }

    /**
     * Keeps only values that satisfy the provided function
     * ___
     * @param func The filter function that accepts one argument.
     * ___
     * @returns {Array}
     *
     * ___
     * @credit Descolada
     * ___
     * @example
     * ; Keeps only colors who's Red channels are over 200
     * cArray.Filter((col) => col.R > 200)
     */
    Filter(_func)
    {
        if not (_func is Func)
            throw ValueError("Filter: _func must be a function", -1)

        r := []

        for v in this
            if _func(v)
                r.Push(v)

        return this := r
    }

    /**
     * Finds a value in the array and returns its index.
     * ___
     * @param value The value to search for.
     * @param start Optional: the index to start the search from. Default is 1.
     * ___
     * @returns {Integer}
     *
     * ___
     * @credit Descolada
     */
    IndexOf(_col, start := 1)
    {
        if not (_col is Color)
            throw ValueError("IndexOf: _col must be a Color object", -1)
        if not (start is Integer)
            throw ValueError("IndexOf: start value must be an integer")

        for i, v in this
        {
            if i < start
                continue

            if v.IsEqual(_col)
                return i
        }

        return 0
    }

    /**
     * Finds a value satisfying the provided function and returns its index.
     * ___
     * @param func The condition function that accepts one argument.
     * @param match Optional: is set to the found value
     * @param start Optional: the index to start the search from. Default is 1.
     * ___
     * @credit Descolada
     * ___
     * @example
     * colorArr.Find((col) => (col.ToNCol("ncol({H}, {W}%, {B}%").Full == "ncol(R70, 36%, 6%)"))
     */
    Find(_func, &match?, start := 1)
    {
        if not (_func is Func)
            throw ValueError("Find: _func must be a function", -1)

        for i, v in this
        {
            if i < start
                continue

            if _func(v)
            {
                match := v
                return i
            }
        }
        return 0
    }

    /**
     * Finds all values satisfying the provided function and returns an array of indexes.
     * ___
     * @param func The condition function that accepts one argument.
     * @param matches Optional: is set to the found value (`ColorArray`)
     * @param start Optional: the index to start the search from. Default is 1.
     * ___
     * @returns {Array} An array of the indexes of the found Colors
     * ___
     * @example
     * colorArr.FindAll((col) => col.GetLuminance() >= .5)
     */
    FindAll(_func, &matches?, start := 1)
    {
        if not (_func is Func)
            throw ValueError("FindAll: _func must be a function", -1)

        results := []
        matches := ColorArray()

        for i, v in this
        {
            if i < start
                continue

            if _func(v)
            {
                results.Push(i)
                matches.Push(v)
            }
        }

        return results
    }

    /**
     * Reverses the ColorArray
     * ___
     * @returns {ColorArray}
     *
     * ___
     * @credit Descolada
     */
    Reverse()
    {
        len := this.Length + 1, max := (len // 2), i := 0

        while ++i <= max
            this.Swap(i, len - i)

        return this
    }

    /**
     * Counts the number of occurrences of a value
     * ___
     * @param value The value to count. Can also be a function.
     *
     * ___
     * @credit Descolada
     */
    Count(col)
    {
        count := 0

        for c in this
            if c == col
                 count++

        return count
    }

    /**
     * Moves the contents of the ColorArray in to a random order.
     * ___
     * @returns {Array}
     *
     * ___
     * @credit Descolada
     */
    Shuffle()
    {
        len := this.Length
        Loop len-1
            this.Swap(A_index, Random(A_index, len))
        return this
    }

    /**
     * Adds the contents of another ColorArray to the end of this one.
     * ___
     * @param cArrays The ColroArrays that are used to extend this one.
     * ___
     * @returns {Array}
     *
     * ___
     * @credit Descolada
     */
    Extend(cArrays*)
    {
        newArr := ColorArray()
        for cArr in cArrays
        {
            if not cArr is ColorArray
                throw ValueError("Extend: argument must be a ColorArray", -1)

            for _, col in cArr
                if col is Color
                    this.Push(col)
                else
                    throw ValueError("Extend: argument must contain Color objects", -1)
        }

        return this
    }

    /**
    * Sorts the ColorArray based on the provided comparison function.
    * If no comparison function is provided, it sorts based on the hexadecimal representation of the colors.
    * Colors are sorted in Ascending order by default. Pass `False` as the first argument to sort in Descending order.
    * ___
    * @param {Boolean} ascending Optional boolean that controls whether the ColorArray is sorted in ascending or descinding order.
    * @param {Function} compareFunc Optional comparison function that takes two Color objects as arguments and returns a number.
    * ___
    * @returns {ColorArray} The sorted ColorArray instance.
    * ___
    * @example
    * colorArr.Sort()
    * colorArr.Sort((a, b) => a.R - b.R)
    * colorArr.Sort((a, b) => a.GetHue() - b.GetHue())
    */
    Sort(ascending := true, compareFunc := "")
    {
        if (compareFunc == "")
            compareFunc := (a, b) => a.ToHex("0x{R}{G}{B}").Full - b.ToHex("0x{R}{G}{B}").Full

        if (this.Length <= 1)
            return this

        pivot := this[this.Length // 2]
        left := ColorArray()
        right := ColorArray()

        for i, item in this
        {
            if (i == this.Length // 2)
                continue
            if (compareFunc(item, pivot) < 0)
                left.Push(item)
            else
                right.Push(item)
        }

        sorted := ColorArray()
        sorted.Push(left.Sort(compareFunc)*)
        sorted.Push(pivot)
        sorted.Push(right.Sort(compareFunc)*)

        for i, color in sorted
            this[i] := color

        if ascending
            return this
        else
            return this.Reverse()
    }

    /**
    * Removes all elements from the ColorArray.
    * ___
    * @returns {ColorArray} The empty ColorArray instance.
    */
    Clear() => this.RemoveAt(1, this.Length)

    /**
    * Calculates the average color of all colors in the ColorArray.
    * ___
    * @returns {Color} A new Color object representing the average color.
    */
    Average() => Color.Average(this)

    /**
    * Multiplies all colors in the ColorArray.
    * ___
    * @returns {Color} A new Color object resulting from the multiplication of all colors.
    */
    Mutiply() => Color.Multiply(this)

    /**
    * Replaces all colors in the ColorArray with random colors.
    * ___
    * @returns {ColorArray}
    */
    Random() => this.Map((col) => col := Color.Random())

    /**
    * Inverts all colors in the ColorArray.
    * ___
    * @returns {ColorArray}
    */
    Invert() => this.Map((col) => col := col.Invert())


    /**
    * Converts all colors in the ColorArray to grayscale.
    * ___
    * @returns {ColorArray}
    */
    Grayscale() => this.Map((col) => col := col.Grayscale())

    /**
    * Applies a sepia filter to all colors in the ColorArray.
    * ___
    * @returns {ColorArray}
    */
    Sepia() => this.Map((col) => col := col.Sepia())

    /**
    * Calculates the complement of all colors in the ColorArray.
    * ___
    * @returns {ColorArray}
    */
    Complement() => this.Map((col) => col := col.Complement())

    /**
    * Shifts the hue of all colors in the ColorArray by the specified number of degrees.
    * ___
    * @param {Number} degrees The number of degrees to shift the hue.
    * ___
    * @returns {ColorArray}
    */
    ShiftHue(degrees)       => this.Map((col) => col := col.ShiftHue(degrees))

    /**
    * Shifts the saturation of all colors in the ColorArray by the specified amount.
    * ___
    * @param {Number} amount The amount to shift the saturation. Positive values increase saturation, negative values decrease it.
    * ___
    * @returns {ColorArray}
    */
    ShiftSaturation(amount) => this.Map((col) => col := col.ShiftSaturation(amount))

    /**
    * Increases the saturation of all colors in the ColorArray by the specified percentage.
    * ___
    * @param {Number} percentage The percentage to increase the saturation.
    * ___
    * @returns {ColorArray} The ColorArray instance with increased saturations.
    */
    Saturate(percentage)    => this.Map((col) => col := col.Saturate(percentage))

    /**
    * Decreases the saturation of all colors in the ColorArray by the specified percentage.
    * ___
    * @param {Number} percentage The percentage to decrease the saturation.
    * ___
    * @returns {ColorArray} The ColorArray instance with decreased saturations.
    */
    Desaturate(percentage)  => this.Map((col) => col := col.Desaturate(percentage))

    /**
    * Shifts the lightness of all colors in the ColorArray by the specified amount.
    * ___
    * @param {Number} amount The amount to shift the lightness. Positive values increase lightness, negative values decrease it.
    * ___
    * @returns {ColorArray} The ColorArray instance with shifted lightness values.
    */
    ShiftLightness(amount)  => this.Map((col) => col := col.ShiftLightness(amount))

    /**
    * Increases the lightness of all colors in the ColorArray by the specified percentage.
    * ___
    * @param {Number} percentage The percentage to increase the lightness.
    * ___
    * @returns {ColorArray} The ColorArray instance with increased lightness values.
    */
    Lighten(percentage)     => this.Map((col) => col := col.Lighten(percentage))

    /**
    * Decreases the lightness of all colors in the ColorArray by the specified percentage.
    * ___
    * @param {Number} percentage The percentage to decrease the lightness.
    * ___
    * @returns {ColorArray} The ColorArray instance with decreased lightness values.
    */
    Darken(percentage)      => this.Map((col) => col := col.Darken(percentage))

    /**
    * Shifts the whiteness of all colors in the ColorArray by the specified amount.
    * ___
    * @param {Number} amount The amount to shift the whiteness. Positive values increase whiteness, negative values decrease it.
    * ___
    * @returns {ColorArray} The ColorArray instance with shifted whiteness values.
    */
    ShiftWhiteness(amount)  => this.Map((col) => col := col.ShiftWhiteness(amount))

    /**
    * Shifts the blackness of all colors in the ColorArray by the specified amount.
    * ___
    * @param {Number} amount The amount to shift the blackness. Positive values increase blackness, negative values decrease it.
    * ___
    * @returns {ColorArray} The ColorArray instance with shifted blackness values.
    */
    ShiftBlackness(amount)  => this.Map((col) => col := col.ShiftBlackness(amount))

    /**
    * Creates a gradient of colors between all colors in the ColorArray.
    * ___
    * @param {Number} [steps=10] The number of steps in the gradient.
    * ___
    * @returns {ColorArray}
    */
    Gradient(steps := 10)   => Color.Gradient(steps, this*)

    /**
    * Sorts the ColorArray by hue.
    * ___
    * @param {Boolean} [ascending=true] Sorts in ascending order if `True`, descending if `False`.
    * @returns {ColorArray}
    */
    SortByHue(ascending := true)        => this.Sort(ascending, (a, b) => a.ToHSL().H - b.ToHSL().H)

    /**
    * Sorts the ColorArray by saturation.
    * ___
    * @param {Boolean} [ascending=true] Sorts in ascending order if `True`, descending if `False`.
    * @returns {ColorArray}
    */
    SortBySaturation(ascending := true) => this.Sort(ascending, (a, b) => a.ToHSL().S - b.ToHSL().S)

    /**
    * Sorts the ColorArray by lightness.
    * ___
    * @param {Boolean} [ascending=true] Sorts in ascending order if `True`, descending if `False`.
    * @returns {ColorArray}
    */
    SortByLightness(ascending := true)  => this.Sort(ascending, (a, b) => a.ToHSL().L - b.ToHSL().L)

    /**
    * Sorts the ColorArray by White Level.
    * ___
    * @param {Boolean} [ascending=true] Sorts in ascending order if `True`, descending if `False`.
    * @returns {ColorArray}
    */
    SortByWhiteness(ascending := true)  => this.Sort(ascending, (a, b) => a.ToHWB().W - b.ToHWB().W)

    /**
    * Sorts the ColorArray by Black Level.
    * ___
    * @param {Boolean} [ascending=true] Sorts in ascending order if `True`, descending if `False`.
    * @returns {ColorArray}
    */
    SortByBlackness(ascending := true)  => this.Sort(ascending, (a, b) => a.ToHWB().B - b.ToHWB().B)

    /**
    * Sorts the ColorArray by luminance.
    * ___
    * @param {Boolean} [ascending=true] Sorts in ascending order if `True`, descending if `False`.
    * @returns {ColorArray}
    */
    SortByLuminance(ascending := true)  => this.Sort(ascending, (a, b) => a.GetLuminance() - b.GetLuminance())

    /**
    * Creates a ColorArray with random colors.
    * ___
    * @param {Integer} count The number of random colors to generate.
    * ___
    * @returns {ColorArray} A new ColorArray instance filled with random colors.
    */
    static Random(count)
    {
        if not (count is Integer)
            throw ValueError("Random: count must be an integer")

        cArr := ColorArray()

        loop count
            cArr.Push(Color.Random())

        return cArr
    }

    /**
    * Creates a ColorArray with a specified capacity, optionally filled with a given color.
    * ___
    * @param {Integer} count The capacity of the ColorArray to create.
    * @param {Color} [col] Optional color to fill the array with.
    * ___
    * @returns {ColorArray}
    */
    static Create(count, col?)
    {
        if not (count is Integer)
            throw ValueError("Create: count must be an integer")

        if IsSet(col) and not (col is Color)
            throw ValueError("Create: col must be a Color object")

        cArr := ColorArray()
        cArr.Capacity := count

        if IsSet(col) and (col is Color)
            loop count
                cArr.Push(col)

        return cArr
    }
}

/**
* Creates a Gradient from a set of colors.
* ___
* @constructor ```Gradient(steps := 10, colors*)```
* ___
* @param {Integer} [steps=10] The number of color steps in the gradient.
* @param {...Color} colors The colors to use as starting points for the gradient.
* ___
* @example
* gradient := Gradient(5, Color.Red, Color.Blue)
* complexGradient := Gradient(20, Color.Red, Color.Green, Color.Blue, Color.Yellow)
*/
class Gradient extends Array
{
    /**
     * The total number of color steps in the gradient.
     * @type {Integer}
     */
    Steps        := 10

    /**
     * The number of steps between each pair of start colors.
     * @type {Integer}
     */
    SubSteps     => Floor(this.Steps / (this.StartColors.Length - 1))

    /**
     * The array of colors used as starting points for the gradient.
     * @type {ColorArray}
     */
    StartColors  := ColorArray()

    /**
     * An array containing the sub-gradients between each pair of start colors.
     * @type {Array}
     */
    SubGradients := []

    /**
    * Creates a new Gradient instance.
    * ___
    * @constructor ```Gradient(steps := 10, colors*)```
    * ___
    * @param {Integer} [steps=10] The number of color steps in the gradient.
    * @param {...Color} colors The colors to use as starting points for the gradient.
    * ___
    * @example
    * gradient := Gradient(5, Color.Red, Color.Blue)
    * complexGradient := Gradient(20, Color.Red, Color.Green, Color.Blue, Color.Yellow)
    */
    __New(steps := 10, colors*)
    {
        this.Steps := steps

        if (colors.Length > 0)
        {
            if colors[1] is Array
                colors := colors[1]

            this.StartColors := ColorArray(colors*)
            this.Interpolate()
        }
    }

    /**
    * Removes all elements from the ColorArray.
    * ___
    * @returns {ColorArray}
    */
    Clear() => this.RemoveAt(1, this.Length)

    /**
     * Keeps only values that satisfy the provided function
     * ___
     * @param func The filter function that accepts one argument.
     * ___
     * @returns {Array}
     *
     * ___
     * @credit Descolada
     * ___
     * @example
     * ; Keeps only colors who's Red channels are over 200
     * _grad.Filter((col) => col.R > 200)
     */
    Filter(_func)
    {
        if not (_func is Func)
            throw ValueError("Filter: _func must be a function", -1)

        r := []

        for v in this
            if _func(v)
                r.Push(v)

        return this := r
    }

    /**
     * Finds a value satisfying the provided function and returns its index.
     * ___
     * @param func The condition function that accepts one argument.
     * @param match Optional: is set to the found value
     * @param start Optional: the index to start the search from. Default is 1.
     * ___
     * @credit Descolada
     * ___
     * @example
     * colorArr.Find((col) => (col.ToNCol("ncol({H}, {W}%, {B}%").Full == "ncol(R70, 36%, 6%)"))
     */
    Find(_func, &match?, start := 1)
    {
        if not (_func is Func)
            throw ValueError("Find: _func must be a function", -1)

        for i, v in this
        {
            if i < start
                continue

            if _func(v)
            {
                match := v
                return i
            }
        }
        return 0
    }

    /**
     * Finds all values satisfying the provided function and returns an array of indexes.
     * ___
     * @param func The condition function that accepts one argument.
     * @param matches Optional: is set to the found value (`ColorArray`)
     * @param start Optional: the index to start the search from. Default is 1.
     * ___
     * @returns {Array} An array of the indexes of the found Colors
     * ___
     * @example
     * colorArr.FindAll((col) => col.GetLuminance() >= .5)
     */
    FindAll(_func, &matches?, start := 1)
    {
        if not (_func is Func)
            throw ValueError("FindAll: _func must be a function", -1)

        results := ColorArray()
        matches := ColorArray()

        for i, v in this
        {
            if i < start
                continue

            if _func(v)
            {
                results.Push(i)
                matches.Push(v)
            }
        }

        return results
    }

    /**
     * Counts the number of occurrences of a value
     * ___
     * @param value The value to count. Can also be a function.
     *
     * ___
     * @credit Descolada
     */
    Count(value)
    {
        count := 0

        if HasMethod(value)
        {
            for v in this
                if value(v?)
                    count++
        }
        else
            for v in this
                if v == value
                    count++

        return count
    }

    /**
     * Applies a function to each element in the Gradient (mutates the Gradient).
     * ___
     * @param func The mapping function that accepts one argument.
     * @param arrays Additional arrays to be accepted in the mapping function
     * ___
     * @returns {ColorArray}
     *
     * ___
     * @credit Descolada
     */
    Map(_func, cArrays*)
    {
        if not (_func is Func)
            throw ValueError("Map: _func must be a function", -1)

        for i, col in this
        {
            var := _func.Bind(col?)

            for _, cArr in cArrays
                var := _func.Bind(cArr.Has(i) ? cArr[i] : unset)

            try var := var()
            this[i] := var
        }

        return this
    }

    /**
     * Applies a function to each element in the array.
     * ___
     * @param func The callback function with arguments Callback(value[, index, array]).
     * ___
     * @returns {Array}
     *
     * ___
     * @credit Descolada
     * ___
     * @example
     * ; Outputs the hex value of ever color in the ColorArray
     * colArray.ForEach((col) => OutputDebug(col.ToHex("#{R}{G}{B}").Full))
     */
    ForEach(_func)
    {
        if not (_func is Func)
            throw ValueError("ForEach: _func must be a function", -1)

        for index, col in this
            _func(col, index, this)

        return this
    }

    /**
     * Finds a value in the array and returns its index.
     * ___
     * @param value The value to search for.
     * @param start Optional: the index to start the search from. Default is 1.
     * ___
     * @returns {Integer}
     *
     * ___
     * @credit Descolada
     */
    IndexOf(_col, start := 1)
    {
        if not (_col is Color)
            throw ValueError("IndexOf: _col must be a Color object", -1)
        if not (start is Integer)
            throw ValueError("IndexOf: start value must be an integer")

        for i, v in this
        {
            if i < start
                continue

            if v.IsEqual(_col)
                return i
        }

        return 0
    }

    /**
    * Interpolates between the start and end colors to create a gradient.
    * ___
    * @throws {Error} If there are fewer than 2 start colors.
    * ___
    * @returns {ColorArray} The ColorArray instance with interpolated colors.
    */
    Interpolate()
    {
        if (this.StartColors.Length < 2)
            throw Error("Gradient requires at least 2 starting colors")

        stepsPerGradient := Floor(this.Steps / (this.StartColors.Length - 1))
        ;MsgBox("Making Gradient`nColors: " this.StartColors.Length "`nGradients: " this.StartColors.Length - 1 "`nSteps: " this.Steps "`nSteps/Grad: " stepsPerGradient)

        loop this.StartColors.Length - 1
        {
            startColor := this.StartColors[A_Index]
            endColor := this.StartColors[A_Index + 1]
            subGradient := this.InterpolateBetween(startColor, endColor, stepsPerGradient)
            this.SubGradients.Push(subGradient)
        }

        if this.Length > 0
            this.Clear() ; Reset the gradient

        for arr in this.SubGradients
            for col in arr
                this.Push(col)

        while (this.Length < this.Steps)
            this.Push(this.StartColors[this.StartColors.Length])
        while (this.Length > this.Steps)
            this.Pop()
    }

    /**
    * Interpolates colors between two given colors.
    * ___
    * @param {Color} startColor The starting color of the interpolation.
    * @param {Color} endColor The ending color of the interpolation.
    * @param {Integer} steps The number of steps to interpolate between the colors.
    * ___
    * @returns {ColorArray} A ColorArray containing the interpolated colors.
    * ___
    * @example
    * subGradient := gradient.InterpolateBetween(Color.Red, Color.Blue, 5)
    */
    InterpolateBetween(startColor, endColor, steps)
    {
        subGradient := ColorArray()
        loop steps
        {
            newColor := startColor.Mix(endColor, 100 * ((A_Index - 1) / steps))
            subGradient.Push(newColor)
        }
        return subGradient
    }

    /**
    * Replaces the first instance of a color in the gradient's starting colors and re-interpolates between it and it's neighbors.
    * ___
    * @param {Color} oldColor The color to be replaced.
    * @param {Color} newColor The new color to replace the old one.
    * ___
    * @returns {Boolean}
    */
    ReplaceColor(oldColor, newColor)
    {
        index := this.StartColors.IndexOf(oldColor)
        if (index > 0)
        {
            this.StartColors[index] := newColor
            this.InterpolateAdjacent(index)
            return true
        }
        return false
    }

    /**
    * Recalculates the interpolation for adjacent colors when a color is changed.
    * ___
    * @param {Integer} index The index of the changed color in the StartColors array.
    * ___
    * @returns {Boolean}
    */
    InterpolateAdjacent(index)
    {
        length := this.StartColors.Length
        if (index < 1 || index > length)
            return false

        ; Recalculate only the affected sub-gradients
        if (index > 1)
        {
            ; Recalculate the gradient between the previous color and the changed color
            this.SubGradients[index - 1] := this.InterpolateBetween(
                this.StartColors[index - 1],
                this.StartColors[index],
                this.SubSteps
            )
        }

        if (index < length)
        {
            ; Recalculate the gradient between the changed color and the next color
            this.SubGradients[index] := this.InterpolateBetween(
                this.StartColors[index],
                this.StartColors[index + 1],
                this.SubSteps
            )
        }

        ; Rebuild the main gradient
        this.Clear()  ; Reset the gradient
        for arr in this.SubGradients
            for col in arr
                this.Push(col)

        ; Adjust the length if necessary
        while (this.Length < this.Steps)
            this.Push(this.StartColors[length])
        while (this.Length > this.Steps)
            this.Pop()

        return true
    }

    /**
    * Inverts all colors in the Gradient.
    * ___
    * @returns {Gradient}
    */
    Invert() => this.Map((col) => col := col.Invert())

    /**
    * Converts all colors in the Gradient to grayscale.
    * ___
    * @returns {Gradient}
    */
    Grayscale() => this.Map((col) => col := col.Grayscale())

    /**
    * Applies a sepia filter to all colors in the Gradient.
    * ___
    * @returns {Gradient}
    */
    Sepia() => this.Map((col) => col := col.Sepia())

    /**
    * Shifts the hue of all colors in the Gradient by the specified number of degrees.
    * ___
    * @param {Number} degrees The number of degrees to shift the hue.
    * ___
    * @returns {Gradient}
    */
    ShiftHue(degrees) => this.Map((col) => col := col.ShiftHue(degrees))

    /**
    * Shifts the saturation of all colors in the Gradient by the specified amount.
    * ___
    * @param {Number} amount The amount to shift the saturation. Positive values increase saturation, negative values decrease it.
    * ___
    * @returns {Gradient}
    */
    ShiftSaturation(amount) => this.Map((col) => col := col.ShiftSaturation(amount))

    /**
    * Increases the saturation of all colors in the Gradient by the specified percentage.
    * ___
    * @param {Number} percentage The percentage to increase the saturation.
    * ___
    * @returns {Gradient} The Gradient instance with increased saturations.
    */
    Saturate(percentage) => this.Map((col) => col := col.Saturate(percentage))

    /**
    * Decreases the saturation of all colors in the Gradient by the specified percentage.
    * ___
    * @param {Number} percentage The percentage to decrease the saturation.
    * ___
    * @returns {Gradient} The Gradient instance with decreased saturations.
    */
    Desaturate(percentage) => this.Map((col) => col := col.Desaturate(percentage))

    /**
    * Shifts the lightness of all colors in the Gradient by the specified amount.
    * ___
    * @param {Number} amount The amount to shift the lightness. Positive values increase lightness, negative values decrease it.
    * ___
    * @returns {Gradient} The Gradient instance with shifted lightness values.
    */
    ShiftLightness(amount) => this.Map((col) => col := col.ShiftLightness(amount))

    /**
    * Increases the lightness of all colors in the Gradient by the specified percentage.
    * ___
    * @param {Number} percentage The percentage to increase the lightness.
    * ___
    * @returns {Gradient} The Gradient instance with increased lightness values.
    */
    Lighten(percentage) => this.Map((col) => col := col.Lighten(percentage))

    /**
    * Decreases the lightness of all colors in the Gradient by the specified percentage.
    * ___
    * @param {Number} percentage The percentage to decrease the lightness.
    * ___
    * @returns {Gradient} The Gradient instance with decreased lightness values.
    */
    Darken(percentage) => this.Map((col) => col := col.Darken(percentage))

    /**
    * Shifts the whiteness of all colors in the Gradient by the specified amount.
    * ___
    * @param {Number} amount The amount to shift the whiteness. Positive values increase whiteness, negative values decrease it.
    * ___
    * @returns {Gradient} The Gradient instance with shifted whiteness values.
    */
    ShiftWhiteness(amount) => this.Map((col) => col := col.ShiftWhiteness(amount))

    /**
    * Shifts the blackness of all colors in the Gradient by the specified amount.
    * ___
    * @param {Number} amount The amount to shift the blackness. Positive values increase blackness, negative values decrease it.
    * ___
    * @returns {Gradient} The Gradient instance with shifted blackness values.
    */
    ShiftBlackness(amount) => this.Map((col) => col := col.ShiftBlackness(amount))

    /**
    * Calculates the complement of all colors in the Gradient.
    * ___
    * @returns {Gradient}
    */
    Complement() => this.Map((col) => col := col.Complement())


    /**
    * Creates a new Gradient with random colors.
    * ___
    * @param {Integer} count The number of random colors to generate.
    * @param {Integer} [steps=10] The number of steps in the whole gradient.
    * ___
    * @returns {Gradient}
    */
    static Random(count, steps := 10)
    {
        if not (count is Integer)
            throw ValueError("Random: count must be an integer")

        cols := []
        loop count
        {
            cols.Push(Color.Random())
        }

        newGrad := Gradient(steps, cols*)
        return newGrad
    }
}