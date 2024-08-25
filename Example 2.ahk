#Requires AutoHotkey v2.0
#Include Color.ahk
#Include ColorPicker.ahk

; Create the main window
mainWin := Gui()
mainWin.Title := "Color Class test"
mainWin.OnEvent("Close", (*) => ExitApp())

columnLabels := ["Start Color", "End Color", "Mixed Color", "Average Color", "Multiplied Color"]
rowLabels    := ["Lighten", "Darken", "Saturate", "Desaturate", "Invert", "Complement"]
columnX := [120, 240, 360, 480, 600]


mainWin.Add("Button" , "x" columnX[1] " y10 w100", "Pick Start Color").OnEvent("Click", LaunchStartColorPicker)
mainWin.Add("Button" , "x" columnX[2] " y10 w100", "Pick End Color").OnEvent("Click", LaunchEndColorPicker)
mainWin.Add("Button" , "x" columnX[3] " y10 w100", "Randomize").OnEvent("Click", RandomizeColors)
pulse    := mainWin.Add("Picture", "x" columnX[4] " y11 w100 h20")
huePulse := mainWin.Add("Picture", "x" columnX[5] " y11 w100 h20")

; Create the GDIObj. We'll use a picture box
gdi := GDIObj(mainWin.AddPic("x0 y40 w800 h675 +0x4"))

; Pre-Generate the Pulse Gradient, we'll make it from red, to blue, and back to red, with 360 total steps
pulseGradient := Gradient(300, Color.Red, Color.Blue, Color.Red)
gradientPos := 1 ; Use this to keep track of where we are in the gradient

; Set the initial color for the Hue shift display,
; we'll shift it by +1 every time the timer fires
; giving a smooth, continuous, rainbow effect.
hueBoxColor := Color.Red

; Making a gradient from a ColorArray
startingColors := ColorArray(Color.Red, Color.Yellow, Color.Lime, Color.Aqua, Color.Blue, Color.Fuchsia)
rgradient := startingColors.Gradient(540)

; An example of the Find() method - set startColor
startingColors.Find((col) => col.Invert().IsEqual(Color("FFFF00")), &startColor)

; Example of IndexOf() - set endColor
endColor := startingColors[startingColors.IndexOf(Color.Red)]

; Example of ForEach() - Show startingColors information
;startingColors.ForEach((c, i, _) => MsgBox("Starting Colors`nIndex: " i "`nColor: " c.ToHex("#{R}{G}{B}").Full))

; Show the window
mainWin.Show("w800 h675")
gdi.Clear()
DrawLabels()
UpdateTopRow()
DrawColors()
CreateGradients()
DrawTempGradient(1000, 30000, 715, 0, 40, 500)

SetTimer(PulseBars, 50)
SetTimer(UpdateGradientAnimation, 10)

UpdateGradientAnimation(*)
{
    global startColor, endColor, cgradient, ggradient, sgradient, rgradient

    startColor := startColor.ShiftHue(2)
    endColor := endColor.ShiftHue(2)

    rgradient.ShiftHue(-2)

    CreateGradients()

    local y := 50
    gdi.DrawGradient(130, 480, 540, 20, cgradient)
    gdi.DrawGradient(130, 505, 540, 20, ggradient)
    gdi.DrawGradient(130, 530, 540, 20, sgradient)
    gdi.DrawGradient(130, 555, 540, 20, rgradient)
    gdi.Render()
}

PulseBars(*)
{
    global hueBoxColor := hueBoxColor.ShiftHue(1)
    global gradientPos := Mod(gradientPos += 1, pulseGradient.Length - 1) + 1
    gdi.DrawRectangle(130, 582, 540, 20, hueBoxColor, hueBoxColor)
    gdi.DrawRectangle(130, 607, 540, 20, pulseGradient[gradientPos], pulseGradient[gradientPos])
}

;Color picker creation
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

; Randomizes start and end colors
RandomizeColors(*)
{
    global startColor := Color.Random()
    global endColor   := Color.Random()
    CreateGradients()
    DrawColors()
}

; ColorPicker event handlers
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
    CreateGradients()
    DrawColors()
}

ExitEndColor(_color)
{
    global endColor := _color
    CreateGradients()
    DrawColors()
}

CreateGradients()
{
    global cgradient := Color.Gradient(540,
                                       startColor,
                                       startColor.Invert(),
                                       Color.Multiply(startColor, endColor),
                                       endColor.Invert(),
                                       endColor)

    ; Create new instances of ColorArray from cgradient, and apply transformations
    global ggradient := ColorArray(cgradient).Grayscale()
    global sgradient := ColorArray(cgradient).Sepia()
}

DrawLabels()
{
    gdi.Clear()
    global columnLabels
    global rowLabels
    global gdi
    CreateGradients()

    for i, label in columnLabels
    {
        gdi.DrawText(columnX[i] + 10, 0, 110, 20, label, Color.Black, , , "Center")
    }

    global y := 0
    for i, prop in rowLabels
    {
        y := 52 + (i - 1) * 30
        gdi.DrawText(10, y, 110, 20, prop, Color.Black, , , "Right")

        for j, label in columnLabels
        {
            gdi.DrawText(columnX[j]+35, y, 65, 20, Color.Gray.ToHex("#{R}{G}{B}").Full, Color.Black)
        }
    }

    gdi.DrawText(10, 232, 110, 20, "Tetradic 40°" , Color.Black, , , "Right")
    gdi.DrawText(10, 282, 110, 20, "Triadic"      , Color.Black, , , "Right")
    gdi.DrawText(10, 332, 110, 20, "Analogous 30°", Color.Black, , , "Right")
    gdi.DrawText(10, 382, 110, 20, "Square"       , Color.Black, , , "Right")
    gdi.DrawText(10, 432, 110, 20, "Monochromatic", Color.Black, , , "Right")
    gdi.DrawText(10, 482, 110, 20, "Gradient"     , Color.Black, , , "Right")
    gdi.DrawText(10, 507, 110, 20, "Grayscale"    , Color.Black, , , "Right")
    gdi.DrawText(10, 532, 110, 20, "Sepia"        , Color.Black, , , "Right")
    gdi.DrawText(10, 557, 110, 20, "Spectrum"     , Color.Black, , , "Right")

    gdi.Render()
}

DrawTempGradient(_min, _max, x, y, width := 20, height := 300, margin := 2)
{

    t := {
        kelvin  : gdi.MeasureText("K°"),
        onek    : gdi.MeasureText(Round(_min / 1000) "k"),
        fifteenk: gdi.MeasureText(Round((_max - _min) / 2) "k"),
        thirtyk : gdi.MeasureText(Round(_max) "k")
    }

    barStartY := y + t.kelvin.Height + margin
    barEndY := barStartY + height

    gdi.DrawText(x + ((width / 2) - (t.kelvin.Width / 2)), y, t.kelvin.Width, t.kelvin.Height, "K°")
    gdi.DrawText(x + width + margin, barStartY - (t.onek.Height / 2), t.onek.Width, t.kelvin.Height, Round(_min / 1000) "k")
    gdi.DrawText(x + width + margin, barStartY + (height / 2) - (t.onek.Height / 2), t.fifteenk.Width, t.fifteenk.Height, Round(((_max - _min) / 2) / 1000) "k")
    gdi.DrawText(x + width + margin, barEndY - (t.thirtyk.Height / 2) - (t.Kelvin.Height / 2), t.thirtyk.Width, t.thirtyk.Height, Round(_max / 1000) "k")

    i := _min
    loop
    {
        if (i > _max)
            break

        gdi.DrawLine(x, y + A_Index + t.kelvin.Height, x + width, y + A_Index + t.kelvin.Height, Color.FromTemp(i))

        i += Round(_max / height)
    }
    gdi.DrawLine(x, (height / 2) + (y + A_Index + t.kelvin.Height), x + width, (height / 2) + (y + A_Index + t.kelvin.Height), Color.Black)

    gdi.Render()
}

UpdateTopRow()
{
    global columnLabels
    global columnX

    colorColumns := [startColor, endColor, startColor.Mix(endColor), Color.Average(startColor, endColor), Color.Multiply(startColor, endColor)]

    for i, col in colorColumns
    {
        UpdateColorDisplay(columnX[i] + 10, 20, col)
    }
    gdi.Render()
}

DrawColors()
{
    global columnLabels
    global rowLabels
    global columnX

    mixedColor      := startColor.Mix(endColor)
    averageColor    := Color.Average(startColor, endColor)
    multipliedColor := Color.Multiply(startColor, endColor)
    colorColumns    := [startColor, endColor, mixedColor, averageColor, multipliedColor]

    y := 52
    for j, col in colorColumns
    {
        UpdateColorDisplay(columnX[j] + 10, 20     , col)
        UpdateColorDisplay(columnX[j] + 10, y      , col.Lighten(20))
        UpdateColorDisplay(columnX[j] + 10, y + 30 , col.Darken(20))
        UpdateColorDisplay(columnX[j] + 10, y + 60 , col.Saturate(20))
        UpdateColorDisplay(columnX[j] + 10, y + 90 , col.Desaturate(20))
        UpdateColorDisplay(columnX[j] + 10, y + 120, col.Invert())
        UpdateColorDisplay(columnX[j] + 10, y + 150, col.Complement())

        UpdateSchemeDisplay(col.Tetradic()      , columnX[j] + 10, y + 180)
        UpdateSchemeDisplay(col.Triadic()       , columnX[j] + 10, y + 230)
        UpdateSchemeDisplay(col.Analogous(30, 6), columnX[j] + 10, y + 280)
        UpdateSchemeDisplay(col.Square()        , columnX[j] + 10, y + 330)
        UpdateSchemeDisplay(col.Monochromatic(6), columnX[j] + 10, y + 380)
    }

    gdi.Render()
}

UpdateColorDisplay(x, y, col, boxSize := 20, margin := 5)
{
    hex := col.ToHex("#{R}{G}{B}").Full
    textDim := gdi.MeasureText(hex)
    cLine := y + ((boxSize / 2) - (textDim.Height / 2))
    gdi.DrawRectangle(x, y, boxSize, boxSize, col, col)
    gdi.DrawRectangle(x + boxSize, cLine, textDim.Width + margin, textDim.Height, Color.White, Color.White)
    gdi.DrawText(x + boxSize + margin, cLine, boxSize, boxSize, hex, Color.Black)
}

UpdateSchemeDisplay(colors, x, y, boxSize := 20, spacing := 0)
{
    totalColors := colors.Length
    columns := Ceil(totalColors / 2)
    rows := Min(2, Ceil(totalColors / columns))

    totalWidth := columns * (boxSize + spacing) - spacing
    startX := x + (totalWidth - columns * (boxSize + spacing) + spacing) / 2

    index := 1
    loop rows
    {
        currentY := y + (A_Index - 1) * (boxSize + spacing)
        colorsInRow := (A_Index == rows && totalColors & 1) ? columns - 1 : columns
        rowStartX := startX + (totalWidth - colorsInRow * (boxSize + spacing) + spacing) / 2

        loop colorsInRow
        {
            if (index > totalColors)
                break
            currentX := rowStartX + (A_Index - 1) * (boxSize + spacing)
            gdi.DrawRectangle(currentX, currentY, boxSize, boxSize, colors[index], colors[index])
            index++
        }
    }
}

class GDIObj
{
    hdc := ""

    __New(ctrl)
    {
        this.ctrl := ctrl
        this.hdc := DllCall("GetDC", "Ptr", this.ctrl.Hwnd, "Ptr")

        ; Create a compatible DC for double buffering
        this.hMemDC := DllCall("CreateCompatibleDC", "Ptr", this.hdc)

        ; Get the dimensions of the control
        this.ctrl.GetPos(,, &w, &h)

        ; Create a compatible bitmap
        this.hBitmap := DllCall("CreateCompatibleBitmap", "Ptr", this.hdc, "Int", w, "Int", h)

        ; Select the bitmap into the memory DC
        this.hOldBitmap := DllCall("SelectObject", "Ptr", this.hMemDC, "Ptr", this.hBitmap)
    }

    __Delete()
    {
        ; Clean up resources
        DllCall("SelectObject", "Ptr", this.hMemDC, "Ptr", this.hOldBitmap)
        DllCall("DeleteObject", "Ptr", this.hBitmap)
        DllCall("DeleteDC", "Ptr", this.hMemDC)
        DllCall("ReleaseDC", "Ptr", this.ctrl.Hwnd, "Ptr", this.hdc)
    }

    Clear(col := Color.White)
    {
        this.ctrl.GetPos(,, &w, &h)
        hBrush := DllCall("CreateSolidBrush", "UInt", col.ToHex("0x{B}{G}{R}").Full)
        DllCall("SelectObject", "Ptr", this.hMemDC, "Ptr", hBrush)
        DllCall("PatBlt", "Ptr", this.hMemDC, "Int", 0, "Int", 0, "Int", w, "Int", h, "UInt", 0xF00062) ; PATCOPY
        DllCall("DeleteObject", "Ptr", hBrush)
    }

    Render()
    {
        ; Copy the contents of the memory DC to the screen
        this.ctrl.GetPos(,, &w, &h)
        DllCall("BitBlt", "Ptr", this.hdc, "Int", 0, "Int", 0, "Int", w, "Int", h, "Ptr", this.hMemDC, "Int", 0, "Int", 0, "UInt", 0xCC0020) ; SRCCOPY
    }

    DrawRectangle(x, y, width, height, borderColor := Color.Black, fillColor := Color.White, filled := true)
    {
        if (filled)
        {
            brush := DllCall("CreateSolidBrush", "UInt", fillColor.ToHex("0x{B}{G}{R}").Full)
            DllCall("SelectObject", "Ptr", this.hMemDC, "Ptr", brush)

            if (borderColor != 0)
            {
                pen := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", borderColor.ToHex("0x{B}{G}{R}").Full)
                oldPen := DllCall("SelectObject", "Ptr", this.hMemDC, "Ptr", pen)
            }
            else
            {
                pen := DllCall("GetStockObject", "Int", 5)  ; NULL_PEN
                oldPen := DllCall("SelectObject", "Ptr", this.hMemDC, "Ptr", pen)
            }

            DllCall("Rectangle", "Ptr", this.hMemDC, "Int", x, "Int", y, "Int", x + width, "Int", y + height)

            DllCall("SelectObject", "Ptr", this.hMemDC, "Ptr", oldPen)
            DllCall("DeleteObject", "Ptr", brush)
            if (borderColor != 0)
                DllCall("DeleteObject", "Ptr", pen)
        }
        else
        {
            pen := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", fillColor.ToHex("0x{B}{G}{R}").Full)
            DllCall("SelectObject", "Ptr", this.hMemDC, "Ptr", pen)
            DllCall("Rectangle", "Ptr", this.hMemDC, "Int", x, "Int", y, "Int", x + width, "Int", y + height)
            DllCall("DeleteObject", "Ptr", pen)
        }
    }

    DrawEllipse(x, y, width, height, col, filled := true)
    {
        if (filled)
        {
            brush := DllCall("CreateSolidBrush", "UInt", col.ToHex("0x{B}{G}{R}").Full)
            DllCall("SelectObject", "Ptr", this.hMemDC, "Ptr", brush)
            DllCall("Ellipse", "Ptr", this.hMemDC, "Int", x, "Int", y, "Int", x + width, "Int", y + height)
            DllCall("DeleteObject", "Ptr", brush)
        }
        else
        {
            pen := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", col.ToHex("0x{B}{G}{R}").Full)
            DllCall("SelectObject", "Ptr", this.hMemDC, "Ptr", pen)
            DllCall("Ellipse", "Ptr", this.hMemDC, "Int", x, "Int", y, "Int", x + width, "Int", y + height)
            DllCall("DeleteObject", "Ptr", pen)
        }
    }

    DrawLine(x1, y1, x2, y2, col, thickness := 1)
    {
        pen := DllCall("CreatePen", "Int", 0, "Int", thickness, "UInt", col.ToHex("0x{B}{G}{R}").Full)
        DllCall("SelectObject", "Ptr", this.hMemDC, "Ptr", pen)
        DllCall("MoveToEx", "Ptr", this.hMemDC, "Int", x1, "Int", y1, "Ptr", 0)
        DllCall("LineTo", "Ptr", this.hMemDC, "Int", x2, "Int", y2)
        DllCall("DeleteObject", "Ptr", pen)
    }

    DrawGradient(x, y, width, height, colors, angle := 0)
    {
        steps := colors.Length

        if (angle == 90 || angle == 270) ; Vertical gradient
        {
            stepHeight := height / steps
            for i, col in colors
            {
                startY := y + (i - 1) * stepHeight
                endY := startY + stepHeightBrush := DllCall("CreateSolidBrush", "UInt", col.ToHex("0x{B}{G}{R}").Full)
                DllCall("SelectObject", "Ptr", this.hMemDC, "Ptr", hBrush)

                rect := Buffer(16)
                NumPut("Int", x, rect, 0)
                NumPut("Int", Round(startY), rect, 4)
                NumPut("Int", x + width, rect, 8)
                NumPut("Int", Round(endY), rect, 12)

                DllCall("FillRect", "Ptr", this.hMemDC, "Ptr", rect, "Ptr", hBrush)
                DllCall("DeleteObject", "Ptr", hBrush)
            }
        }
        else ; Horizontal gradient (default) or any other angle
        {
            stepWidth := width / steps
            for i, col in colors
            {
                startX := x + (i - 1) * stepWidth
                endX := startX + stepWidth

                hBrush := DllCall("CreateSolidBrush", "UInt", col.ToHex("0x{B}{G}{R}").Full)
                DllCall("SelectObject", "Ptr", this.hMemDC, "Ptr", hBrush)

                rect := Buffer(16)
                NumPut("Int", Round(startX), rect, 0)
                NumPut("Int", y, rect, 4)
                NumPut("Int", Round(endX), rect, 8)
                NumPut("Int", y + height, rect, 12)

                DllCall("FillRect", "Ptr", this.hMemDC, "Ptr", rect, "Ptr", hBrush)
                DllCall("DeleteObject", "Ptr", hBrush)
            }
        }
    }

    DrawText(x, y, width, height, text, col := Color.Black, fontSize := 15, fontName := "Arial", align := "left")
    {
        DllCall("SetTextColor", "Ptr", this.hMemDC, "UInt", col.ToHex("0x{B}{G}{R}").Full)
        DllCall("SetBkMode", "Ptr", this.hMemDC, "Int", 1)  ; TRANSPARENT

        hFont := DllCall("CreateFont", "Int", fontSize, "Int", 0, "Int", 0, "Int", 0
            , "Int", 400, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0
            , "UInt", 0, "UInt", 0, "UInt", 0, "Str", fontName)

        DllCall("SelectObject", "Ptr", this.hMemDC, "Ptr", hFont)

        rect := Buffer(16)
        NumPut("Int", x, rect, 0)
        NumPut("Int", y, rect, 4)
        NumPut("Int", x + width, rect, 8)
        NumPut("Int", y + height, rect, 12)

        format := 0
        if (align = "center")
            format |= 0x1  ; DT_CENTER
        else if (align = "right")
            format |= 0x2  ; DT_RIGHT
        format |= 0x100  ; DT_VCENTER

        DllCall("DrawText", "Ptr", this.hMemDC, "Str", text, "Int", -1, "Ptr", rect, "UInt", format)

        DllCall("DeleteObject", "Ptr", hFont)
    }

    MeasureText(text, fontSize := 15, fontName := "Arial")
    {
        hFont := DllCall("CreateFont", "Int", fontSize, "Int", 0, "Int", 0, "Int", 0
            , "Int", 400, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0
            , "UInt", 0, "UInt", 0, "UInt", 0, "Str", fontName)

        DllCall("SelectObject", "Ptr", this.hMemDC, "Ptr", hFont)

        size := Buffer(8)
        DllCall("GetTextExtentPoint32", "Ptr", this.hdc, "Str", text, "Int", StrLen(text), "Ptr", size)
        return {Width: NumGet(size, 0, "Int"), Height: NumGet(size, 4, "Int")}
    }
}