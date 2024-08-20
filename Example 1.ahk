#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Color.ahk
#Include ColorPicker.ahk

/**
 * This example will allow you to pick a color or type a color in using either
 * the color function syntax (eg: "rgb(123, 61, 93)", "ncol(B20, 40%, 5%)", "hsl(120, 70%, 50%)", etc...)
 * or using Hex (RGB, ARGB, RRGGBB, or AARRGGBB with or without "0x" or "#"), or you can use
 * RGB or RGBA ("R, G, B" or "R, G, B, A"). If the input is valid, it will convert it to all supported
 * formats of the Color class. You can then click on any of the group boxes to copy the full color string
 * to the clipboard.
 */

MainGui := Gui()
MainGui.Title := "Color Converter"
MainGui.SetFont("s10")

MainGui.Add("Text", "x10 y10 w100", "Input Color:")
inputEdit := MainGui.Add("Edit", "x10 y30 w200 vInputColor")
inputEdit.SetFont("s10", "Consolas")
pickBtn    := MainGui.Add("Button", "x10 y+7 w200", "Pick Color")
convertBtn := MainGui.Add("Button", "x220 y10 w80 h80", "Convert")
colorPreview := MainGui.Add("Progress", "x310 y10 w320 h80 +Background000000")

labels := ["Hex", "RGB", "HSL", "HWB", "CMYK", "NCol", "XYZ", "Lab", "YIQ"]
labelControls := Map()
componentControls := Map()

gridWidth := 3
gridHeight := 3
boxWidth := 200
boxHeight := 120
marginX := 10
marginY := 10

for index, label in labels {
    col := Mod(index - 1, gridWidth)
    row := (index - 1) // gridWidth
    x := 10 + col * (boxWidth + marginX)
    y := 100 + row * (boxHeight + marginY)

    groupBox := MainGui.Add("GroupBox", "x" x " y" y " w" boxWidth " h" boxHeight, label)
    labelControls[label] := MainGui.Add("Text", "x" (x+10) " y" (y+20) " w180 vResult" label)
    labelControls[label].SetFont("s10", "Consolas")
    componentControls[label] := Map()
    componentControls[label]["1"] := MainGui.Add("Text", "x" (x+10) " y" (y+40) " w180 c707070 vComponents" label "1")
    componentControls[label]["2"] := MainGui.Add("Text", "x" (x+10) " y" (y+60) " w180 c707070 vComponents" label "2")
    componentControls[label]["3"] := MainGui.Add("Text", "x" (x+10) " y" (y+80) " w180 c707070 vComponents" label "3")
    componentControls[label]["1"].SetFont("s10", "Consolas")
    componentControls[label]["2"].SetFont("s10", "Consolas")
    componentControls[label]["3"].SetFont("s10", "Consolas")

    if (label == "CMYK") {
        componentControls[label]["4"] := MainGui.Add("Text", "x" (x+10) " y" (y+100) " w180 c707070 vComponents" label "4")
        componentControls[label]["4"].SetFont("s10", "Consolas")
    }

    clickArea := MainGui.Add("Text", "x" x " y" y " w" boxWidth " h" boxHeight " +BackgroundTrans")
    clickArea.OnEvent("Click", CopyColorValue.Bind(label))
}

picker := ColorPicker(False)
picker.OnUpdate := (_col) => colorPreview.Opt("+Background" . _col.ToHex("{R}{G}{B}").Full)
picker.OnExit := PickerExit
PickerExit(Color.Black) ; Set up the initial color to display

MainGui.Show()

convertBtn.OnEvent("Click", ConvertColor)
pickBtn.OnEvent("Click", (*) => picker.Start())
MainGui.OnEvent("Close", (*) => ExitApp())

PickerExit(_col)
{
    global col := _col
    inputEdit.Value := col.Full
    ConvertColor(col)
}

CopyColorValue(colorType, *)
{
    fullValue := labelControls[colorType].Text
    A_Clipboard := fullValue
    ToolTip("Copied: " fullValue)
    SetTimer(() => ToolTip(), -2000)
}

ConvertColor(*)
{
    input := inputEdit.Value

    try
    {
        ; build this RegEx to match all color formats except hex, and pull out their type and channels
        chT  := "(?<type>[a-z]+)\("                 ; Matches the origin color type "ncol", "rgb", "hsl", etc...
        ch1  := "(?<ch1>[RYGCBM]?\d+(\.\d+)?)%?, ?" ; The first channel of the color
        ch2  := "(?<ch2>-?\d+(\.\d+)?)%?, ?"        ; The second channel of the color
        ch3  := "(?<ch3>-?\d+(\.\d+)?)%?(\)|, )?"   ; The third channel of the color
        ch4  := "(?<ch4>-?\d+(\.\d+)?)?%?\)"        ; The fourth channel of the color (if color supports it)
        funcNeedle := chT . ch1 . ch2 . ch3 . ch4

        ; build this RegEx to match Hex (with or without 0x or #), RGB (in R, G, B format), and RGBA (in R, G, B, A format)
        hex := "(?<hexSign>#|0x)?(?<hexVal>[0-9a-f]{3,8})(?!,)" ; Hex value, including an optional preceding "0x" or "#"
        rCh := "(?<rgb>(?<r>\d{1,3}),\s*" ; Red
        gCh := "(?<g>\d{1,3}),\s*"        ; Green
        bCh := "(?<b>\d{1,3})"            ; Blue
        aCh := "(?:,\s*(?<a>\d{1,3}))?)"  ; Alpha
        rgbaNeedle := hex "|" rCh . gCh . bCh . aCh

        if (RegExMatch(input, funcNeedle, &match))
        {
            switch (match.type)
            {
                case "rgb":
                    col := Color(match.ch1, match.ch2, match.ch3)
                case "rgba":
                    col := Color(match.ch1, match.ch2, match.ch3, match.ch4)
                case "hsl":
                    col := Color.FromHSL(match.ch1, match.ch2, match.ch3)
                case "hwb":
                    col := Color.FromHWB(match.ch1, match.ch2, match.ch3)
                case "cmyk":
                    col := Color.FromCMYK(match.ch1, match.ch2, match.ch3, match.ch4)
                case "ncol":
                    col := Color.FromNCol(match.ch1, match.ch2, match.ch3)
                case "xyz":
                    col := Color.FromXYZ(match.ch1, match.ch2, match.ch3)
                case "lab":
                    col := Color.FromLab(match.ch1, match.ch2, match.ch3)
                case "yiq":
                    col := Color.FromYIQ(match.ch1, match.ch2, match.ch3)
                default:
                    throw Error("Error in color syntax (function).")
            }
        }
        else if RegExMatch(input, rgbaNeedle, &match)
        {
            if match.hexSign and match.hexVal
                col := Color(match.hexVal)
            else if match.rgb and match.a
                col := Color(match.r, match.g, match.b, match.a)
            else if match.rgb
                col := Color(match.r, match.g, match.b)
            else
                throw Error("Error in color syntax (non-function).")
        }

        colorPreview.Opt("+Background" . col.ToHex("{R}{G}{B}").Full)

        hex := col.ToHex("#{R}{G}{B}")
        labelControls["Hex"].Text := hex.Full
        componentControls["Hex"]["1"].Text := "R: " hex.R
        componentControls["Hex"]["2"].Text := "G: " hex.G
        componentControls["Hex"]["3"].Text := "B: " hex.B

        labelControls["RGB"].Text := col.Full
        componentControls["RGB"]["1"].Text := "R: " col.R
        componentControls["RGB"]["2"].Text := "G: " col.G
        componentControls["RGB"]["3"].Text := "B: " col.B

        hsl := col.ToHSL()
        labelControls["HSL"].Text := hsl.Full
        componentControls["HSL"]["1"].Text := "H: " hsl.H
        componentControls["HSL"]["2"].Text := "S: " hsl.S
        componentControls["HSL"]["3"].Text := "L: " hsl.L

        hwb := col.ToHWB()
        labelControls["HWB"].Text := hwb.Full
        componentControls["HWB"]["1"].Text := "H: " hwb.H
        componentControls["HWB"]["2"].Text := "W: " hwb.W
        componentControls["HWB"]["3"].Text := "B: " hwb.B

        cmyk := col.ToCMYK()
        labelControls["CMYK"].Text := cmyk.Full
        componentControls["CMYK"]["1"].Text := "C: " cmyk.C
        componentControls["CMYK"]["2"].Text := "M: " cmyk.M
        componentControls["CMYK"]["3"].Text := "Y: " cmyk.Y
        componentControls["CMYK"]["4"].Text := "K: " cmyk.K

        ncol := col.ToNCol()
        labelControls["NCol"].Text := ncol.Full
        componentControls["NCol"]["1"].Text := "H: " ncol.H
        componentControls["NCol"]["2"].Text := "W: " ncol.W
        componentControls["NCol"]["3"].Text := "B: " ncol.B

        xyz := col.ToXYZ()
        labelControls["XYZ"].Text := xyz.Full
        componentControls["XYZ"]["1"].Text := "X: " Round(xyz.X, 2)
        componentControls["XYZ"]["2"].Text := "Y: " Round(xyz.Y, 2)
        componentControls["XYZ"]["3"].Text := "Z: " Round(xyz.Z, 2)

        lab := col.ToLab()
        labelControls["Lab"].Text := lab.Full
        componentControls["Lab"]["1"].Text := "L: " Round(lab.L, 2)
        componentControls["Lab"]["2"].Text := "a: " Round(lab.a, 2)
        componentControls["Lab"]["3"].Text := "b: " Round(lab.b, 2)

        yiq := col.ToYIQ()
        labelControls["YIQ"].Text := yiq.Full
        componentControls["YIQ"]["1"].Text := "Y: " Round(yiq.Y, 3)
        componentControls["YIQ"]["2"].Text := "I: " Round(yiq.I, 3)
        componentControls["YIQ"]["3"].Text := "Q: " Round(yiq.Q, 3)
    }
    catch Error as err
    {
        MsgBox("Error converting color: " err.Message)
    }
}
