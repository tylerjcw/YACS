#Requires AutoHotKey v2.0
#Include ColorPicker.ahk
#Include Color.ahk

TestGui := Gui()
TestGui.Title := "Color Class Test"
TestGui.Opt("+Resize")

startColor := Color("0xFF234567")
endColor   := Color.Random()

; Pre-Generate the Pulse Gradient, we'll make it from red, to green, and back to red
pulseGradient := Color.Red.Gradient(300, Color.Green, Color.Red)
for i, col in pulseGradient
    pulseGradient[i] := col.ToHex("{R}{G}{B}").Full ; convert every Color in the array into a hex string formatted for use with Progress control
SetTimer(PulseBar, 1000) ; Start the pulse timer

; Set variable for hue shift pulse, we'll add one to it and loop it back to zero when it hits 360, giving a rainbow effect
hueShift := 0
SetTimer(PulseHue, 10) ; set the hue shift pulse timer

CreateControls()
UpdateControls()
TestGui.Show()

MsgBox("
    (
        This demonstration shows some of the Capabilities of the Color class.
        Every individual box is displaying an instance of the Color class.

        There are 149 boxes in total:
        Single color operations, 70 boxes arranged in a grid (5x14).
        There are also 20 boxes for Analogous colors
        15 Boxes for Triadic colors
        And 54 boxes for the gradient.
    )")

PulseBar(*)
{
    for col in pulseGradient
    {
        controls["Pulse"].Opt("Background" col)
        Sleep(1)
    }
}

PulseHue(*)
{
    ; Add one degree to the hue every iteration, looping back to 0 when we hit 360 degrees.
    global hueShift := Mod(hueShift + 1, 360)

    ; Create the color from Hue, Saturation, and Lightness, then convert it to a formatted hex string
    hex := Color.FromHSL(hueShift, 50, 50).ToHex("{R}{G}{B}").Full

    ; Set the control's background color to the new hex value
    controls["HuePulse"].Opt("Background" hex)
}

LaunchStartColorPicker(*)
{
    picker := ColorPicker(False,, UpdateStartColor)
    picker.DefaultCaptureSize := 5
    picker.DefaultZoomFactor := 12
    picker.ViewMode := "crosshair"
    picker.OnExit := ExitStartColor
    picker.Start()
}

LaunchEndColorPicker(*)
{
    picker := ColorPicker(False,, UpdateEndColor)
    picker.DefaultCaptureSize := 5
    picker.DefaultZoomFactor := 12
    picker.ViewMode := "crosshair"
    picker.OnExit := ExitEndColor
    picker.Start()
}

RandomizeColors(*)
{
        global startColor := Color.Random()
        global endColor   := Color.Random()
        UpdateControls()
}

UpdateStartColor(_color)
{
    global startColor := _color
    UpdateTopRow()
}

UpdateEndColor(_color)
{
    global endColor := _color
    UpdateTopRow()
}

ExitStartColor(_color)
{
    global startColor := _color
    UpdateControls()
}

ExitEndColor(_color)
{
    global endColor := _color
    UpdateControls()
}

CreateControls()
{
    global controls := Map() ;54B929
    
    columnLabels := ["Start Color", "End Color", "Mixed Color", "Average Color", "Multiplied Color"]
    columnX := [120, 240, 360, 480, 600]

    TestGui.Add("Button"  , "x" columnX[1] " y10 w100", "Pick Start Color").OnEvent("Click", LaunchStartColorPicker)
    TestGui.Add("Button"  , "x" columnX[2] " y10 w100", "Pick End Color").OnEvent("Click", LaunchEndColorPicker)
    TestGui.Add("Button"  , "x" columnX[3] " y10 w100", "Randomize").OnEvent("Click", RandomizeColors)
    controls["Pulse"] := TestGui.Add("Progress", "x" columnX[4] " y10 w100 h22")
    controls["HuePulse"] := TestGui.Add("Progress", "x" columnX[5] " y10 w100 h22")
    
    for i, label in columnLabels
    {
        TestGui.Add("Text", "x" columnX[i] " y50 w100 Center", label)
        controls[label] := TestGui.Add("Progress", "x" columnX[i]+10 " y70 w20 h20")
        controls[label "Text"] := TestGui.Add("Text", "x" columnX[i]+35 " y70 w80 h20 Left", "")
    }
    
    colorProperties := ["Hex → RGB", "RGB → RGB", "HSL → RGB", "HWB → RGB", "CMYK → RGB", "NCol → RGB", "Invert", "Lighten", "Darken", "Saturate", "Desaturate", "Grayscale", "Complement"]
    
    for i, prop in colorProperties
    {
        y := 100 + (i - 1) * 30
        TestGui.Add("Text", "x10 y" y " w100 Right", prop)

        for j, label in columnLabels
        {
            controls[label prop] := TestGui.Add("Picture", "x" columnX[j]+10 " y" y-2 " w20 h20")
            controls[label prop "Text"] := TestGui.Add("Text", "x" columnX[j]+35 " y" y " w80 h20 Left", "")
        }
    }

    ; Add Analogous and Triadic displays
    y := 495
    TestGui.Add("Text", "x10 y" y " w100 Right", "Analogous")
    for j, label in columnLabels
    {
        controls[label "Analogous1"] := TestGui.Add("Progress", "x" columnX[j]+10 " y" y-5 " w20 h20")
        controls[label "Analogous2"] := TestGui.Add("Progress", "x" columnX[j]+30 " y" y-5 " w20 h20")
        controls[label "Analogous3"] := TestGui.Add("Progress", "x" columnX[j]+10 " y" y+15 " w20 h20")
        controls[label "Analogous4"] := TestGui.Add("Progress", "x" columnX[j]+30 " y" y+15 " w20 h20")
        controls[label "AnalogousText"] := TestGui.Add("Text" , "x" columnX[j]+5  " y" y+40 " w80 h20 Center")
    }

    y += 50
    TestGui.Add("Text", "x10 y" y " w100 Right", "Triadic")
    for j, label in columnLabels
    {
        controls[label "Triadic1"] := TestGui.Add("Progress", "x" columnX[j]+10 " y" y-5 " w20 h20")
        controls[label "Triadic2"] := TestGui.Add("Progress", "x" columnX[j]+30 " y" y-5 " w20 h20")
        controls[label "Triadic3"] := TestGui.Add("Progress", "x" columnX[j]+20 " y" y+15 " w20 h20")
        controls[label "TriadicText"] := TestGui.Add("Text" , "x" columnX[j]+5  " y" y+40 " w80 h20 Center")
    }

    ; Gradient display
    y += 50
    TestGui.Add("Text", "x10 y" y " w100 Right", "Gradient")
    Loop 54
    {
        controls["Gradient" A_Index] := TestGui.Add("Progress", "x" 120+(A_Index-1)*10 " y" y-5 " w10 h20")
    }
}

UpdateTopRow()
{
    columnLabels := ["Start Color", "End Color", "Mixed Color", "Average Color", "Multiplied Color"]
    colorColumns := [startColor, endColor, startColor.Mix(endColor), Color.Average(startColor, endColor), Color.Multiply(startColor, endColor)]
    
    for i, _color in colorColumns
    {
        UpdateColorDisplay(columnLabels[i], _color)
    }
}

UpdateControls()
{
    mixedColor := startColor.Mix(endColor)
    averageColor := Color.Average(startColor, endColor)
    multipliedColor := Color.Multiply(startColor, endColor)

    colorColumns := [startColor, endColor, mixedColor, averageColor, multipliedColor]
    columnLabels := ["Start Color", "End Color", "Mixed Color", "Average Color", "Multiplied Color"]

    for i, _color in colorColumns
    {
        UpdateColorDisplay(columnLabels[i], _color)
        UpdateColorDisplay(columnLabels[i] "Hex → RGB", _color)
        UpdateColorDisplay(columnLabels[i] "RGB → RGB", Color.FromRGB(_color.R, _color.G, _color.B))

        hsl := _color.ToHSL()
        UpdateColorDisplay(columnLabels[i] "HSL → RGB", Color.FromHSL(hsl.H, hsl.S, hsl.L))

        hwb := _color.ToHWB()
        UpdateColorDisplay(columnLabels[i] "HWB → RGB", Color.FromHWB(hwb.H, hwb.W, hwb.B))

        cmyk := _color.ToCMYK()
        UpdateColorDisplay(columnLabels[i] "CMYK → RGB", Color.FromCMYK(cmyk.C, cmyk.M, cmyk.Y, cmyk.K))

        ncol := _color.ToNCol()
        UpdateColorDisplay(columnLabels[i] "NCol → RGB", Color.FromNCol(ncol.H, ncol.W, ncol.B))
        UpdateColorDisplay(columnLabels[i] "Invert", _color.Invert())
        UpdateColorDisplay(columnLabels[i] "Lighten", _color.Lighten(20))
        UpdateColorDisplay(columnLabels[i] "Darken", _color.Darken(20))
        UpdateColorDisplay(columnLabels[i] "Saturate", _color.Saturate(20))
        UpdateColorDisplay(columnLabels[i] "Desaturate", _color.Desaturate(20))
        UpdateColorDisplay(columnLabels[i] "Grayscale", _color.Grayscale())
        UpdateColorDisplay(columnLabels[i] "Complement", _color.Complement())
    }

    ; Update Analogous and Triadic displays
    for i, _color in colorColumns
    {
        analogous := _color.Analogous(30, 4)
        triadic := _color.Triadic()

        UpdateColorDisplay(columnLabels[i] "Analogous1", analogous[1])
        UpdateColorDisplay(columnLabels[i] "Analogous2", analogous[2])
        UpdateColorDisplay(columnLabels[i] "Analogous3", analogous[3])
        UpdateColorDisplay(columnLabels[i] "Analogous4", analogous[4])

        UpdateColorDisplay(columnLabels[i] "Triadic1", triadic[1])
        UpdateColorDisplay(columnLabels[i] "Triadic2", triadic[2])
        UpdateColorDisplay(columnLabels[i] "Triadic3", triadic[3])
    }

    gradient := startColor.Gradient(54, Color.Random(), Color.Random(), Color.Random(), endColor)
    Loop 54
    {
        hex := gradient[A_Index].ToHex("{R}{G}{B}").Full
        controls["Gradient" A_Index].Opt("c" hex " Background" hex)
    }
}

UpdateColorDisplay(label, _color)
{
    adjustedColor := Color.FromRGB(
        Max(0, _color.R - 32),
        Max(0, _color.G - 32),
        Max(0, _color.B - 32)
    )
    hex := adjustedColor.ToHex("{R}{G}{B}").Full
    controls[label].Opt("c" hex " Background" hex)

    if (controls.Has(label "Text"))
    {
        controls[label "Text"].Value := _color.ToHex("0x{R}{G}{B}").Full
    }
}

TestGui.OnEvent("Close", (*) => ExitApp())