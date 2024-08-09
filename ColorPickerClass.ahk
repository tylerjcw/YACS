#Requires AutoHotKey v2.0

class ColorPicker
{
    FontName           := "Consolas"
    FontSize           := 16
    ViewMode           := "grid"
    BorderWidth        := 2
    CrosshairWidth     := 1
    GridWidth          := 1
    CenterDotRadius    := 2
    TextPadding        := 6
    DefaultCaptureSize := 19
    DefaultZoomFactor  := 10
    LargeJumpAmount    := 16
    UpdateInterval     := 16
    Clip               := False
    TargetHWND         := 0
    Callback           := 0

    ; Color Configuration. Press "i" to cycle between the two color sets.
    ;=====================  SET 1  ===  SET 2  ==========================;
    TextFGColors     := [ 0xFFFFFF  , 0x000000   ] ; 0xBBGGRR Text Foreground
    TextBGColors     := [ 0x000000  , 0xFFFFFF   ] ; 0xBBGGRR Text Background
    BorderColors     := [ 0xFF000000, 0xFFFFFFFF ] ; 0xAABBGGRR Border Color
    CrosshairColors  := [ 0xFF000000, 0xFFFFFFFF ] ; 0xAABBGGRR Crosshair Color
    GridColors       := [ 0xFF000000, 0xFFFFFFFF ] ; 0xAABBGGRR Grid Color
    HighlightColors  := [ 0xFFFFFFFF, 0xFF000000 ] ; 0xAABBGGRR Highlight Color for selected grid square

    ; Output format strings. These control how the values in the return object are formatted. The HexFullFormatString also controls what is displayed in the preview gui.
    RGBFullFormatString := "{1:u}, {2:u}, {3:u}" ; Format(RGBFullFormatString, "0x" r, "0x" g, "0x" b) (Switch to {3:i}, {2:i}, {1:i} for BGR)
    RGBPartFormatString := "{1:u}"               ; Format(RGBPartFormatString, "0x" r)
    HexFullFormatString := "0x{1:s}{2:s}{3:s}"   ; Format(HexFullFormatString, r, g, b) (Switch to "#{3:s}{2:s}{1:s}" for BGR)
    HexPartFormatString := "{1:s}"               ; Format(HexPartFormatString, r)

    ; These Shouldn't Need to be touched
    Anchored         := False
    Frozen           := False
    AnchoredX        := 0
    AnchoredY        := 0
    TextHeight       := 0
    ColorSet         := 0
    PreviewGUI       := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80000 -DPIScale")
    ZoomFactor       := this.DefaultZoomFactor
    CaptureSize      := this.DefaultCaptureSize
    HighlightCenter  := True
    ScaledZoomFactor := 0
    PreviewWidth     := 0
    PreviewHeight    := 0

    DPIScale         => this.GetDpiScale(this.PreviewGUI.HWND) 
    TextFGColor      => this.TextFGColors[this.ColorSet + 1]
    TextBGColor      => this.TextBGColors[this.ColorSet + 1]
    BorderColor      => this.BorderColors[this.ColorSet + 1]
    CrosshairColor   => this.CrosshairColors[this.ColorSet + 1]
    GridColor        => this.GridColors[this.ColorSet + 1]
    HighlightColor   => this.HighlightColors[this.ColorSet + 1]
    PreviewXOffset   => Round(this.CaptureSize / 2) + this.BorderWidth + 1
    PreviewYOffset   => Round(this.CaptureSize / 2) + this.BorderWidth + 1

    Position
    {
        get
        {
            MouseGetPos(&x, &y)
            return {X: x, Y: y}
        }
    }

    Color := {}

    __New(clip := false, hwnd := 0, callback := 0)
    {
        if (hwnd != 0) and (WinExist(hwnd))
            this.TargetHWND := hwnd

        if (callback != 0) and (callback is func)
            this.Callback := callback
    }

    static Run(clip := false, hwnd := 0, callback := 0)
    {
        picker := ColorPicker(clip, hwnd, callback)
        return picker.Start()
    }

    Start(clip := false, hwnd := 0, callback := 0)
    {
        if (hwnd != 0) and (WinExist(hwnd))
            this.TargetHWND := hwnd

        if (callback != 0) and (callback is func)
            this.Callback := callback

        try dpiContext := DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")

        CoordMode "Mouse", "Screen"
        CoordMode "Pixel", "Screen"
        Suspend(True)
        Hotkey("*LButton", this.BlockLButton, "On S")

        previewGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80000 -DPIScale")
        previewGui.Show()
        updateHandler := (*) => this.CaptureAndPreview()
        SetTimer(updateHandler, this.UpdateInterval)

        ; Set the cursor to crosshair
        hCross := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32515)
        for cursorId in [32512, 32513, 32514, 32515, 32516, 32631, 32640, 32641, 32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650, 32651]
            DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", hCross, "UInt", 2, "Int", 0, "Int", 0, "UInt", 0), "UInt", cursorId)

        ; If a Valid HWND was passed as an argument, confine the cursor to that window
        if (this.TargetHWND != 0) and WinExist("ahk_id " this.TargetHWND)
        {
            windowRect := Buffer(16)
            DllCall("GetWindowRect", "Ptr", this.TargetHWND, "Ptr", windowRect)
            confineLeft   := NumGet(windowRect, 0, "Int")
            confineTop    := NumGet(windowRect, 4, "Int")
            confineRight  := NumGet(windowRect, 8, "Int")
            confineBottom := NumGet(windowRect, 12, "Int")

            DllCall("ClipCursor", "Ptr", windowRect)
        }

        ; Main loop
        while (True)
        {
            ;MouseGetPos(&mouseX, &mouseY)
            ;dpiScale    := this.GetDpiScale(this.PreviewGUI.HWND)

            if (this.TargetHWND != 0) and WinExist("ahk_id " this.TargetHWND)
            {
                mouseX := Max(confineLeft, Min(this.Position.X, confineRight))
                mouseY := Max(confineTop, Min(this.Position.Y, confineBottom))
            }
            else
            {
                mouseX := this.Position.X
                mouseY := this.Position.Y
            }

            if this.Anchored
            {
                this.PreviewGui.Move(this.AnchoredX, this.AnchoredY)
            }
            else
            {
                this.PreviewWidth  := this.CaptureSize * this.ZoomFactor + this.BorderWidth * 2
                this.PreviewHeight := this.CaptureSize * this.ZoomFactor + this.BorderWidth * 2 + this.TextHeight

                newX := mouseX + this.PreviewXOffset
                newY := mouseY + this.PreviewYOffset

                monitorCount := MonitorGetCount()
                ;dpiScaleScale := this.GetDpiScale(this.PreviewGui.Hwnd)
                Loop monitorCount
                {
                    MonitorGet(A_Index, &left, &top, &right, &bottom)

                    if (mouseX >= left && mouseX < right && mouseY >= top && mouseY < bottom)
                    {
                        ; Apply DPI scaling to preview dimensions
                        scaledPreviewWidth := this.PreviewWidth * this.DPIScale
                        scaledPreviewHeight := this.PreviewHeight * this.DPIScale

                        ; Adjust for right edge
                        if (newX + scaledPreviewWidth > right)
                            newX := mouseX - this.PreviewXOffset * this.DPIScale - scaledPreviewWidth

                        ; Adjust for bottom edge, including taskbar
                        if (newY + scaledPreviewHeight > bottom)
                            newY := mouseY - this.PreviewYOffset * this.DPIScale - scaledPreviewHeight

                        ; Ensure the preview stays within the monitor bounds
                        newX := Max(left, Min(newX, right - scaledPreviewWidth))
                        newY := Max(top, Min(newY, bottom - scaledPreviewHeight))

                        break
                    }
                }

                previewGui.Move(newX, newY)
            }

            ; "LButton", "Enter", or "NumpadEnter" Captures HEX, Shift in combination with them captures RGB
            if GetKeyState("LButton", "P") or GetKeyState("Enter", "P") or GetKeyState("NumpadEnter", "P") or GetKeyState("Space", "P")
            {
                if GetKeyState("Shift", "P")
                    outType := "RGB"
                else
                    outType := "HEX"
                break
            }

            ; "Escape" or "Q" exits
            if GetKeyState("Escape", "P") or GetKeyState("q", "P")
            {
                outType := "Exit"
                break
            }

            ; "C" cycles between color schemes
            if GetKeyState("c", "P")
            {
                this.ColorSet := !this.ColorSet

                KeyWait("c")
            }

            ; "A" toggles anchoring
            if GetKeyState("a", "P") or GetKeyState("NumpadDot", "P")
            {
                this.Anchored := !this.Anchored
                if this.Anchored
                {
                    this.AnchoredX := mouseX + this.PreviewXOffset
                    this.AnchoredY := mouseY + this.PreviewYOffset
                }

                if !KeyWait("a") or !KeyWait("NumpadDot")
                    continue
            }

            ; "M" cycles between view modes (grid, crosshair, none)
            if GetKeyState("m", "P")
            {
                viewModes := [ "grid", "crosshair", "none" ]
                index := 0

                for mode in viewModes
                    if (mode == this.ViewMode)
                        index := A_Index

                if index == 0
                {
                    this.ViewMode := "none"
                    index := 3
                }

                this.ViewMode := viewModes[Mod(index, viewModes.Length) + 1]
                KeyWait("m")
            }

            ; "Left" or "Numpad4" moves cursor left one pixel
            if GetKeyState("Left", "P") or GetKeyState("Numpad4", "P")
            {
                if GetKeyState("Shift", "P")
                    MouseMove(-this.LargeJumpAmount, 0, 0, "R")
                else
                    MouseMove(-1, 0, 0, "R")

                if !KeyWait("Left", "T0.05") or !KeyWait("Numpad4", "T0.05")
                    continue
            }

            ; "Right" or "Numpad6" moves cursor right one pixel
            if GetKeyState("Right", "P") or GetKeyState("Numpad6", "P")
            {
                if GetKeyState("Shift", "P")
                    MouseMove(this.LargeJumpAmount, 0, 0, "R")
                else
                    MouseMove(1, 0, 0, "R")

                if !KeyWait("Right", "T0.05") or !KeyWait("Numpad6", "T0.05")
                    continue
            }

            ; "Up" or "Numpad8" moves cursor up one pixel
            if GetKeyState("Up", "P") or GetKeyState("Numpad8", "P")
            {
                if GetKeyState("Shift", "P")
                    MouseMove(0, -this.LargeJumpAmount, 0, "R")
                else
                    MouseMove(0, -1, 0, "R")

                if !KeyWait("Up", "T0.05") or !KeyWait("Numpad8", "T0.05")
                    continue
            }

            ; "Down" or "Numpad2" moves cursor down one pixel
            if GetKeyState("Down", "P") or GetKeyState("Numpad2", "P")
            {
                if GetKeyState("Shift", "P")
                    MouseMove(0, this.LargeJumpAmount, 0, "R")
                else
                    MouseMove(0, 1, 0, "R")

                if !KeyWait("Down", "T0.05") or !KeyWait("Numpad2", "T0.05")
                    continue
            }

            ; "H" toggles highlighting the center pixel
            if GetKeyState("h", "P")
            {
                this.HighlightCenter := !this.HighlightCenter
                KeyWait("h")
            }

            ; "-" or "NumpadSub" decreases capture size
            if GetKeyState("-", "P") or GetKeyState("NumpadSub", "P")
            {
                this.CaptureSize := Max(1, --this.CaptureSize)

                if !KeyWait("-") or !KeyWait("NumpadSub")
                    continue
            }

            ; "=" or "NumpadAdd" increases capture size
            if GetKeyState("=", "P") or GetKeyState("NumpadAdd", "P")
            {
                this.CaptureSize := ++this.CaptureSize

                if !KeyWait("=") or !KeyWait("NumpadAdd")
                    continue
            }

            ; "[" or "NumpadDiv" decreases zoom factor
            if GetKeyState("[", "P") or GetKeyState("NumpadDiv", "P")
            {
                this.ZoomFactor := Max(1, --this.ZoomFactor)

                if !KeyWait("[") or !KeyWait("NumpadDiv")
                    continue
            }

            ; "]" or "NumpadMult" increases zoom factor
            if GetKeyState("]", "P") or GetKeyState("NumpadMult", "P")
            {
                this.ZoomFactor := ++this.ZoomFactor
                if !KeyWait("]") or !KeyWait("NumpadMult")
                    continue
            }

            ; "0" or "Numpad0" resets zoom and capture size
            if GetKeyState("0", "P") or GetKeyState("Numpad0", "P")
            {
                this.ZoomFactor := this.DefaultZoomFactor
                this.CaptureSize := this.DefaultCaptureSize

                if !KeyWait("0") or !KeyWait("Numpad0")
                    continue
            }

            ; "F" or "Numpad5" toggles freezing the preview update cycle
            if GetKeyState("f", "P") or GetKeyState("Numpad5", "P")
            {
                frozen := !frozen

                if !KeyWait("f") or !KeyWait("Numpad5")
                    continue
            }

            Sleep(10)
        }

        if (this.Clip == True) and ((outType == "HEX") or (outType == "RGB"))
            A_Clipboard := (outType == "HEX" ? this.Color.Hex.Full : this.Color.RGB.Full)

        ; Cleanup
        SetTimer(updateHandler, 0)  ; Turn off the timer
        DllCall("SystemParametersInfo", "UInt", 0x57, "UInt", 0, "Ptr", 0, "UInt", 0)  ; Reset cursor
        DllCall("DestroyCursor", "Ptr", hCross)
        Sleep(50)
        Hotkey("*LButton", "Off")
        Suspend(False)

        previewGui.Destroy()
        try DllCall("SetThreadDpiAwarenessContext", "ptr", dpiContext, "ptr")

        if (this.TargetHWND != 0) and WinExist("ahk_id " this.TargetHWND)
            DllCall("ClipCursor", "Ptr", 0)

        return (outType == "Exit" ? False : this.Color)
    }

    GetDpiScale(guiHwnd)
    {
        dpi := DllCall("User32.dll\GetDpiForWindow", "Ptr", guiHwnd, "UInt")
        return dpi / 96
    }

    BlockLButton(*)
    {
        KeyWait("LButton", "D")
        return
    }

    CaptureAndPreview()
    {
        if not this.Frozen
        {
            ; Get cursor position
            CoordMode "Mouse", "Screen"
            CoordMode "Pixel", "Screen"
            MouseGetPos(&cursorX, &cursorY)
            ;this.DPIScale := this.GetDpiScale(this.PreviewGUI.Hwnd)

            ; Calculate capture region
            halfSize := (this.CaptureSize - 1) // 2
            left     := cursorX - halfSize
            top      := cursorY - halfSize
            width    := this.CaptureSize
            height   := this.CaptureSize

            ; Capture screen region
            hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
            hMemDC := DllCall("CreateCompatibleDC", "Ptr", hDC, "Ptr")
            hBitmap := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", width, "Int", height, "Ptr")
            DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hBitmap)
            DllCall("BitBlt", "Ptr", hMemDC, "Int", 0, "Int", 0, "Int", width, "Int", height, "Ptr", hDC, "Int", left, "Int", top, "UInt", 0x00CC0020)

            ; Get color of central pixel
            centralX     := width // 2
            centralY     := height // 2
            centralColor := DllCall("GetPixel", "Ptr", hMemDC, "Int", centralX, "Int", centralY, "UInt")
            hexColor     := Format("#{:06X}", centralColor & 0xFFFFFF)

            _tempCol := { B: SubStr(hexColor, 2, 2), G: SubStr(hexColor, 4, 2), R: SubStr(hexColor, 6, 2) }
            hexColor := Format(this.HexFullFormatString, _tempCol.R, _tempCol.G, _tempCol.B)
            _color := {
                RGB: {
                    R: Format(this.RGBPartFormatString, "0x" _tempCol.R),
                    G: Format(this.RGBPartFormatString, "0x" _tempCol.G),
                    B: Format(this.RGBPartFormatString, "0x" _tempCol.B),
                    Full: Format(this.RGBFullFormatString, "0x" _tempCol.R, "0x" _tempCol.G, "0x" _tempCol.B)
                },
                Hex: {
                    R: Format(this.HexPartFormatString, _tempCol.R),
                    G: Format(this.HexPartFormatString, _tempCol.G),
                    B: Format(this.HexPartFormatString, _tempCol.B),
                    Full: Format(this.HexFullFormatString, _tempCol.R, _tempCol.G, _tempCol.B)
                }
            }

            this.ScaledZoomFactor := Round(this.ZoomFactor * this.DPIScale)
            this.PreviewWidth     := this.CaptureSize * this.ScaledZoomFactor
            this.PreviewHeight    := this.CaptureSize * this.ScaledZoomFactor

            ; Prepare to draw text
            scaledFontSize := Round(this.FontSize * this.DPIScale)
            LOGFONT := Buffer(92, 0)
            NumPut("Int", scaledFontSize * 4, LOGFONT, 0)
            StrPut(this.FontName, LOGFONT.Ptr + 28, 32, "UTF-16")
            hFont := DllCall("CreateFontIndirect", "Ptr", LOGFONT, "Ptr")
            size := Buffer(8)
            DllCall("GetTextExtentPoint32", "Ptr", hDC, "Str", "Ay", "Int", 2, "Ptr", size)
            this.TextHeight := Round((NumGet(size, 4, "Int") + this.TextPadding) * this.DPIScale)

            ; Conclude size calculations
            this.TotalHeight := (this.PreviewHeight + this.TextHeight)

            ; Create high-resolution memory DC
            hHighResDC := DllCall("CreateCompatibleDC", "Ptr", hDC, "Ptr")
            hHighResBitmap := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", this.PreviewWidth * 4, "Int", this.TotalHeight * 4, "Ptr")
            DllCall("SelectObject", "Ptr", hHighResDC, "Ptr", hHighResBitmap)
            DllCall("SetStretchBltMode", "Ptr", hHighResDC, "Int", 4)
            DllCall("StretchBlt", "Ptr", hHighResDC, "Int", 0, "Int", 0, "Int", this.PreviewWidth * 4, "Int", this.PreviewHeight * 4, "Ptr", hMemDC, "Int", 0, "Int", 0, "Int", width, "Int", height, "UInt", 0x00CC0020)

            ; Draw background rectangle
            hBrush := DllCall("CreateSolidBrush", "UInt", this.TextBGColor, "Ptr")
            rect := Buffer(16, 0)
            NumPut("Int", 0, rect, 0)
            NumPut("Int", this.PreviewHeight * 4, rect, 4)
            NumPut("Int", this.PreviewWidth * 4, rect, 8)
            NumPut("Int", this.TotalHeight * 4, rect, 12)
            DllCall("FillRect", "Ptr", hHighResDC, "Ptr", rect, "Ptr", hBrush)
            DllCall("DeleteObject", "Ptr", hBrush)

            ; Render text at high resolution
            DllCall("SelectObject", "Ptr", hHighResDC, "Ptr", hFont)
            DllCall("SetTextColor", "Ptr", hHighResDC, "UInt", this.TextFGColor)
            DllCall("SetBkColor", "Ptr", hHighResDC, "UInt", this.TextBGColor)
            textWidth := DllCall("GetTextExtentPoint32", "Ptr", hHighResDC, "Str", hexColor, "Int", StrLen(hexColor), "Ptr", rect)
            textX := (this.PreviewWidth * 4 - NumGet(rect, 0, "Int")) // 2
            textY := this.PreviewHeight * 4 + (this.TextHeight * 4 - scaledFontSize * 4) // 2
            DllCall("TextOut", "Ptr", hHighResDC, "Int", textX, "Int", textY, "Str", hexColor, "Int", StrLen(hexColor))

            ; Calculate the offset based on captureSize
            offset := (Mod(this.CaptureSize, 2) == 0) ? Round(this.ZoomFactor * 2) : 0
            if (this.ViewMode == "crosshair")
            {
                centerX := Round(this.PreviewWidth * 2) + offset
                centerY := Round(this.PreviewHeight * 2) + offset
                halfZoom := Round(this.ZoomFactor * 2)
                hCrosshairPen := DllCall("CreatePen", "Int", 0, "Int", Round(this.CrosshairWidth * this.DPIScale) * 4, "UInt", this.CrosshairColor & 0xFFFFFF, "Ptr")
                DllCall("SelectObject", "Ptr", hHighResDC, "Ptr", hCrosshairPen)
                DllCall("MoveToEx", "Ptr", hHighResDC, "Int", centerX, "Int", 0, "Ptr", 0)
                DllCall("LineTo", "Ptr", hHighResDC, "Int", centerX, "Int", this.PreviewHeight * 4)
                DllCall("MoveToEx", "Ptr", hHighResDC, "Int", 0, "Int", centerY, "Ptr", 0)
                DllCall("LineTo", "Ptr", hHighResDC, "Int", this.PreviewWidth * 4, "Int", centerY)
                if this.HighlightCenter
                {
                    hInnerCrosshairPen := DllCall("CreatePen", "Int", 0, "Int", Round(this.CrosshairWidth * this.DPIScale) * 4, "UInt", this.HighlightColor & 0xFFFFFF, "Ptr")
                    DllCall("SelectObject", "Ptr", hHighResDC, "Ptr", hInnerCrosshairPen)
                    DllCall("MoveToEx", "Ptr", hHighResDC, "Int", centerX, "Int", centerY - halfZoom, "Ptr", 0)
                    DllCall("LineTo", "Ptr", hHighResDC, "Int", centerX, "Int", centerY + halfZoom)
                    DllCall("MoveToEx", "Ptr", hHighResDC, "Int", centerX - halfZoom, "Int", centerY, "Ptr", 0)
                    DllCall("LineTo", "Ptr", hHighResDC, "Int", centerX + halfZoom, "Int", centerY)
                    DllCall("DeleteObject", "Ptr", hInnerCrosshairPen)
                }
                DllCall("DeleteObject", "Ptr", hCrosshairPen)
            }
            else if (this.ViewMode == "grid")
            {
                ; Calculate the center square
                if Mod(this.CaptureSize, 2) == 0
                    centerIndex := this.CaptureSize // 2 + 1
                else
                    centerIndex := this.CaptureSize // 2 + (this.CaptureSize & 1)

                ; Draw grid
                hGridPen := DllCall("CreatePen", "Int", 0, "Int", Round(this.GridWidth * this.DPIScale) * 4, "UInt", this.GridColor & 0xFFFFFF, "Ptr")
                DllCall("SelectObject", "Ptr", hHighResDC, "Ptr", hGridPen)

                Loop this.CaptureSize + 1
                {
                    x := (A_Index - 1) * this.ScaledZoomFactor * 4
                    DllCall("MoveToEx", "Ptr", hHighResDC, "Int", x, "Int", 0, "Ptr", 0)
                    DllCall("LineTo", "Ptr", hHighResDC, "Int", x, "Int", this.PreviewHeight * 4)
                    DllCall("MoveToEx", "Ptr", hHighResDC, "Int", 0, "Int", x, "Ptr", 0)
                    DllCall("LineTo", "Ptr", hHighResDC, "Int", this.PreviewWidth * 4, "Int", x)
                }

                if this.HighlightCenter
                {
                    ; Highlight the center or lower-right of center square
                    hHighlightPen := DllCall("CreatePen", "Int", 0, "Int", Round(this.GridWidth * this.DPIScale) * 4, "UInt", this.HighlightColor & 0xFFFFFF, "Ptr")
                    DllCall("SelectObject", "Ptr", hHighResDC, "Ptr", hHighlightPen)
                    DllCall("MoveToEx", "Ptr", hHighResDC, "Int", (centerIndex - 1) * this.ScaledZoomFactor * 4, "Int", (centerIndex - 1) * this.ScaledZoomFactor * 4, "Ptr", 0)
                    DllCall("LineTo", "Ptr", hHighResDC, "Int", centerIndex * this.ScaledZoomFactor * 4, "Int", (centerIndex - 1) * this.ScaledZoomFactor * 4)
                    DllCall("LineTo", "Ptr", hHighResDC, "Int", centerIndex * this.ScaledZoomFactor * 4, "Int", centerIndex * this.ScaledZoomFactor * 4)
                    DllCall("LineTo", "Ptr", hHighResDC, "Int", (centerIndex - 1) * this.ScaledZoomFactor * 4, "Int", centerIndex * this.ScaledZoomFactor * 4)
                    DllCall("LineTo", "Ptr", hHighResDC, "Int", (centerIndex - 1) * this.ScaledZoomFactor * 4, "Int", (centerIndex - 1) * this.ScaledZoomFactor * 4)
                    DllCall("DeleteObject", "Ptr", hHighlightPen)
                }

                DllCall("DeleteObject", "Ptr", hGridPen)
            }
            else if this.HighlightCenter
            {
                ; Draw a dot in the center
                centerX := Round(this.PreviewWidth * 2) + offset
                centerY := Round(this.PreviewHeight * 2) + offset
                dotSize := Round(4 * this.DPIScale) * this.CenterDotRadius
                hDotBrush := DllCall("CreateSolidBrush", "UInt", this.HighlightColor & 0xFFFFFF, "Ptr")
                DllCall("SelectObject", "Ptr", hHighResDC, "Ptr", hDotBrush)
                DllCall("Ellipse", "Ptr", hHighResDC, "Int", centerX - Round(dotSize * this.DPIScale), "Int", centerY - Round(dotSize * this.DPIScale), "Int", centerX + Round(dotSize * this.DPIScale), "Int", centerY + Round(dotSize * this.DPIScale))
                DllCall("DeleteObject", "Ptr", hDotBrush)
            }

            ; Draw border
            hBorderPen := DllCall("CreatePen", "Int", 0, "Int", this.BorderWidth * 4, "UInt", this.BorderColor & 0xFFFFFF, "Ptr")
            DllCall("SelectObject", "Ptr", hHighResDC, "Ptr", hBorderPen)
            DllCall("MoveToEx", "Ptr", hHighResDC, "Int", 0, "Int", 0, "Ptr", 0)
            DllCall("LineTo", "Ptr", hHighResDC, "Int", this.PreviewWidth * 4, "Int", 0)
            DllCall("LineTo", "Ptr", hHighResDC, "Int", this.PreviewWidth * 4, "Int", this.TotalHeight * 4)
            DllCall("LineTo", "Ptr", hHighResDC, "Int", 0, "Int", this.TotalHeight * 4)
            DllCall("LineTo", "Ptr", hHighResDC, "Int", 0, "Int", 0)

            ; Draw separator line
            DllCall("MoveToEx", "Ptr", hHighResDC, "Int", 0, "Int", this.PreviewHeight * 4, "Ptr", 0)
            DllCall("LineTo", "Ptr", hHighResDC, "Int", this.PreviewWidth * 4, "Int", this.PreviewHeight * 4)
            DllCall("DeleteObject", "Ptr", hBorderPen)

            ; Create preview DC and scale down from high-res DC
            hPreviewDC := DllCall("CreateCompatibleDC", "Ptr", hDC, "Ptr")
            hPreviewBitmap := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", this.PreviewWidth, "Int", this.TotalHeight, "Ptr")
            DllCall("SelectObject", "Ptr", hPreviewDC, "Ptr", hPreviewBitmap)
            DllCall("SetStretchBltMode", "Ptr", hPreviewDC, "Int", 4)
            DllCall("StretchBlt", "Ptr", hPreviewDC, "Int", 0, "Int", 0, "Int", this.PreviewWidth, "Int", this.TotalHeight, "Ptr", hHighResDC, "Int", 0, "Int", 0, "Int", this.PreviewWidth * 4, "Int", this.TotalHeight * 4, "UInt", 0x00CC0020)

            ; Update preview GUI
            hPreviewHWND := WinExist("A")
            DllCall("UpdateLayeredWindow", "Ptr", hPreviewHWND, "Ptr", 0, "Ptr", 0, "Int64*", this.PreviewWidth | (this.TotalHeight << 32), "Ptr", hPreviewDC, "Int64*", 0, "UInt", 0, "UInt*", 0xFF << 16, "UInt", 2)

            ; Clean up
            DllCall("DeleteObject", "Ptr", hFont)
            DllCall("DeleteDC", "Ptr", hPreviewDC)
            DllCall("DeleteObject", "Ptr", hPreviewBitmap)
            DllCall("DeleteDC", "Ptr", hHighResDC)
            DllCall("DeleteObject", "Ptr", hHighResBitmap)
            DllCall("DeleteDC", "Ptr", hMemDC)
            DllCall("DeleteObject", "Ptr", hBitmap)
            DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)

            if (this.Callback != 0) and (this.Callback is func)
                this.Callback.Call(_color)
        }
    }
}