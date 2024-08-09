#Requires AutoHotKey v2.0

/**
 * ColorPicker class for encapsulating the color picker functionality.
 */
 class ColorPicker
 {
    ; Configuration variables
    /** @property {String} FontName The font to use for the color preview text. Can be any font installed on your system. */
    FontName := "Maple Mono"

    /** @property {Number} FontSize The font size for the color preview text. */
    FontSize           := 16

    /** @property {String} ViewMode The view mode of the color picker. Can be "crosshair", "grid", or any other value which will result in no overlay. */
    ViewMode           := "grid"

    /** @property {Integer} UpdateInterval The interval at which the preview will update, in milliseconds. 16ms = ~60 updates / second. */
    UpdateInterval     := 16

    /** @property {Boolean} HighlightCenter If True, highlights the pixel that the color is copied from. */
    HighlightCenter    := True

    /** @property {Integer} BorderWidth Thickness of preview border, in pixels. */
    BorderWidth        := 4

    /** @property {Integer} CrosshairWidth Thickness of crosshair lines, in pixels. */
    CrosshairWidth     := 1

    /** @property {Integer} GridWidth Thickness of grid lines, in pixels. */
    GridWidth          := 1

    /** @property {Integer} CenterDotRadius Radius of the Center Dot when not in "grid" or "crosshair" mode, in pixels. */
    CenterDotRadius    := 2

    /** @property {Integer} TextPadding The padding added above and below the preview Hex String, in pixels (half above, half below) */
    TextPadding        := 6

    /** @property {Integer} DefaultCaptureSize The size of area you want to capture around the cursor in pixels (N by N square) */
    DefaultCaptureSize := 19

    /** @property {Integer} DefaultZoomFactor How much to multiply each pixel by. Default is 10x. */
    DefaultZoomFactor  := 10

    /** @property {Integer} How many pixels to move the preview window by when holding shift and moving it with the keyboard. */
    LargeJumpAmount    := 16

    ; Color Configuration. Press "i" to cycle between the two color sets.
    ;=====================  SET 1  ===  SET 2  ==========================;
    /** @property {Integer[]} TextFGColors 0xBBGGRR Text Foreground colors. Supports 2 indices, any more will be ignored. */
    TextFGColors     := [ 0xFFFFFF  , 0x000000   ]

    /** @property {Integer[]} TextBGColors 0xBBGGRR Text Background colors. Supports 2 indices, any more will be ignored. */
    TextBGColors     := [ 0x000000  , 0xFFFFFF   ]

    /** @property {Integer[]} BorderColors 0xAABBGGRR Border colors. Supports 2 indices, any more will be ignored. */
    BorderColors     := [ 0xFF000000, 0xFFFFFFFF ]

    /** @property {Integer[]} CrosshairColors 0xAABBGGRR Crosshair Color. Supports 2 indices, any more will be ignored. */
    CrosshairColors  := [ 0xFF000000, 0xFFFFFFFF ]

    /** @property {Integer[]} GridColors 0xAABBGGRR Grid Color. Supports 2 indices, any more will be ignored. */
    GridColors       := [ 0xFF000000, 0xFFFFFFFF ]

    /** @property {Integer[]} HighlightColors 0xAABBGGRR Highlight Color for selected grid square. Supports 2 indices, any more will be ignored. */
    HighlightColors  := [ 0xFFFFFFFF, 0xFF000000 ]

    ; Output Format Configuration
    ;========================================================================;
    /** @property {String} RGBFullFormatString The format string used to format the RGB.Full property */
    RGBFullFormatString := "{1:u}, {2:u}, {3:u}"

    /** @property {String} RGBPartFormatString The format string used to format individual RGB components. */
    RGBPartFormatString := "{1:u}"

    /** @property {String} HexFullFormatString The format string used to format the Hex.Full property */
    HexFullFormatString := "0x{1:s}{2:s}{3:s}"

    /** @property {String} HexPartFormatString The format string used to format individual Hex components. */
    HexPartFormatString := "{1:s}"

    /** @property {String} HSLFullFormatString The format string used to format the HSL.Full property */
    HSLFullFormatString := "{1:s}, {2:s}%, {3:s}%"

    /** @property {String} HSLHueFormatString The format string used to format the Hue HSL component. */
    HSLHueFormatString := "{1:s}"

    /** @property {String} HSLPercentFormatString The format string used to format saturation and lightness HSL components. */
    HSLPercentFormatString := "{1:s}%"

    /** @property {Object} Color An object containing the current color in Hex and RGB formats */
    Color := {Hex:{R:0,G:0,B:0,Full:0}, RGB:{R:0,G:0,B:0,Full:0}}

    /** @property {Boolean} Clip Whether to automatically copy the selected color to clipboard. */
    Clip := False

    /** @property {Number} TargetHWND The window or control handle to confine the color picker to. Default is 0 */
    TargetHWND := 0

    /** @property {Function} Callback The function called when the picker is updated. Passed the `ColorPicker.Color` object. */
    Callback := 0

    ; Nothing below this line should need to be changed
    ;===========================================================================;
    ColorSet := 0
    TextFGColor    => this.TextFGColors[this.ColorSet + 1]
    TextBGColor    => this.TextBGColors[this.ColorSet + 1]
    BorderColor    => this.BorderColors[this.ColorSet + 1]
    CrosshairColor => this.CrosshairColors[this.ColorSet + 1]
    GridColor      => this.GridColors[this.ColorSet + 1]
    HighlightColor => this.HighlightColors[this.ColorSet + 1]

    /**
     * Creates a new instance of `ColorPicker`
     * @param {boolean} [clip=False] Whether to copy the selected color to clipboard.
     * @param {number} [hwnd=0] The handle of the target window to confine the picker to.
     * @param {Function} [callback=0] A callback function to be called with the selected color.
     */
    __New(clip := False, hwnd := 0, callback := 0)
    {
        if (hwnd != 0) and (WinExist(hwnd))
            this.TargetHWND := hwnd

        if (callback != 0) and (callback is func)
            this.Callback := callback

        this.Clip := clip
    }

    /**
     * Runs the `ColorPicker` with default settings.
     * @param {boolean} [clip=True] Whether to copy the selected color to clipboard.
     * @param {number} [hwnd=0] The handle of the target window to confine the picker to.
     * @param {Function} [callback=0] A callback function to be called with the selected color.
     * @returns {Boolean | Object} The `Color` object if a color was chosen, `False` otherwise.
     */
    static Run(clip := True, hwnd := 0, callback := 0)
    {
        picker := ColorPicker(clip, hwnd, callback)
        return picker.Start()
    }

    /**
     * Starts the current instance of `ColorPicker`.
     * @param {Boolean} [clip=True] Whether to copy the selected color to clipboard.
     * @param {Number} [hwnd=0] The handle of the target window to confine the picker to.
     * @param {Function} [callback=0] A callback function to be called with the selected color.
     * @returns {Boolean | Object} The `Color` object if a color was chosen, `False` otherwise.
     */
    Start(clip := False, hwnd := 0, callback := 0)
    {
        startColor := this.Color

        if (hwnd != 0) and (WinExist(hwnd))
            this.TargetHWND := hwnd

        if (callback != 0) and (callback is func)
            this.Callback := callback

        this.Clip := clip

        try dpiContext := DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")

        GetDpiScale(guiHwnd)
        {
            dpi := DllCall("User32.dll\GetDpiForWindow", "Ptr", guiHwnd, "UInt")
            return dpi / 96
        }

        RGBToHSL(color)
        {
            r := (color >> 16 & 0xFF) / 255
            g := (color >> 8 & 0xFF) / 255
            b := (color & 0xFF) / 255
        
            max := Max(r, g, b)
            min := Min(r, g, b)
            l := (max + min) / 2
        
            if (max == min)
            {
                h := 0
                s := 0
            }
            else
            {
                d := max - min
                s := (l > 0.5) ? d / (2 - max - min) : d / (max + min)
        
                if (max == r)
                    h := (g - b) / d + (g < b ? 6 : 0)
                else if (max == g)
                    h := (b - r) / d + 2
                else
                    h := (r - g) / d + 4
        
                h /= 6
            }

            hue        := Round(h * 360)
            saturation := Round(s * 100)
            lightness  := Round(l * 100)
        
            return {
                H: Format(this.HSLHueFormatString, hue),
                S: Format(this.HSLPercentFormatString, saturation),
                L: Format(this.HSLPercentFormatString, lightness),
                Full: Format(this.HSLFullFormatString, hue, saturation, lightness)
            }
        }

        BlockLButton(*)
        {
            KeyWait("LButton", "D")
            return
        }

        CaptureAndPreview(*)
        {
            if not frozen
            {
                ; Get cursor position
                CoordMode "Mouse", "Screen"
                CoordMode "Pixel", "Screen"
                MouseGetPos(&cursorX, &cursorY)
                dpiScale := GetDpiScale(previewGui.Hwnd)

                ; Calculate capture region
                halfSize := (captureSize - 1) // 2
                left     := cursorX - halfSize
                top      := cursorY - halfSize
                width    := captureSize
                height   := captureSize

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
                hexColor     := Format("{:06X}", centralColor & 0xFFFFFF)
                _tempCol := { B: SubStr(hexColor, 1, 2), G: SubStr(hexColor, 3, 2), R: SubStr(hexColor, 5, 2) }
                hexColor := Format(this.HexFullFormatString, _tempCol.R, _tempCol.G, _tempCol.B)
                this.Color := {
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
                    },
                    HSL: RGBToHSL(hexColor)
                }

                ; Calculate preview size
                scaledZoomFactor := Round(zoomFactor * dpiScale)
                previewWidth := captureSize * scaledZoomFactor
                previewHeight := captureSize * scaledZoomFactor

                ; Prepare to draw text
                scaledFontSize := Round(this.FontSize * dpiScale)
                LOGFONT := Buffer(92, 0)
                NumPut("Int", scaledFontSize * 4, LOGFONT, 0)
                StrPut(this.FontName, LOGFONT.Ptr + 28, 32, "UTF-16")
                hFont := DllCall("CreateFontIndirect", "Ptr", LOGFONT, "Ptr")
                size := Buffer(8)
                DllCall("GetTextExtentPoint32", "Ptr", hDC, "Str", "Ay", "Int", 2, "Ptr", size)
                textHeight := Round((NumGet(size, 4, "Int") + this.TextPadding) * dpiScale)

                ; Conclude size calculations
                totalHeight := (previewHeight + textHeight)

                ; Create high-resolution memory DC
                hHighResDC := DllCall("CreateCompatibleDC", "Ptr", hDC, "Ptr")
                hHighResBitmap := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", previewWidth * 4, "Int", totalHeight * 4, "Ptr")
                DllCall("SelectObject", "Ptr", hHighResDC, "Ptr", hHighResBitmap)
                DllCall("SetStretchBltMode", "Ptr", hHighResDC, "Int", 4)
                DllCall("StretchBlt", "Ptr", hHighResDC, "Int", 0, "Int", 0, "Int", previewWidth * 4, "Int", previewHeight * 4, "Ptr", hMemDC, "Int", 0, "Int", 0, "Int", width, "Int", height, "UInt", 0x00CC0020)

                ; Draw background rectangle
                hBrush := DllCall("CreateSolidBrush", "UInt", this.TextBGColor, "Ptr")
                rect := Buffer(16, 0)
                NumPut("Int", 0, rect, 0)
                NumPut("Int", previewHeight * 4, rect, 4)
                NumPut("Int", previewWidth * 4, rect, 8)
                NumPut("Int", totalHeight * 4, rect, 12)
                DllCall("FillRect", "Ptr", hHighResDC, "Ptr", rect, "Ptr", hBrush)
                DllCall("DeleteObject", "Ptr", hBrush)

                ; Render text at high resolution
                DllCall("SelectObject", "Ptr", hHighResDC, "Ptr", hFont)
                DllCall("SetTextColor", "Ptr", hHighResDC, "UInt", this.TextFGColor)
                DllCall("SetBkColor", "Ptr", hHighResDC, "UInt", this.TextBGColor)
                textWidth := DllCall("GetTextExtentPoint32", "Ptr", hHighResDC, "Str", hexColor, "Int", StrLen(hexColor), "Ptr", rect)
                textX := (previewWidth * 4 - NumGet(rect, 0, "Int")) // 2
                textY := previewHeight * 4 + (textHeight * 4 - scaledFontSize * 4) // 2
                DllCall("TextOut", "Ptr", hHighResDC, "Int", textX, "Int", textY, "Str", hexColor, "Int", StrLen(hexColor))

                ; Calculate the offset based on captureSize
                offset := (Mod(captureSize, 2) == 0) ? Round(zoomFactor * 2) : 0
                if (this.ViewMode == "crosshair")
                {
                    centerX := Round(previewWidth * 2) + offset
                    centerY := Round(previewHeight * 2) + offset
                    halfZoom := Round(zoomFactor * 2)
                    hCrosshairPen := DllCall("CreatePen", "Int", 0, "Int", Round(this.CrosshairWidth * dpiScale) * 4, "UInt", this.CrosshairColor & 0xFFFFFF, "Ptr")
                    DllCall("SelectObject", "Ptr", hHighResDC, "Ptr", hCrosshairPen)
                    DllCall("MoveToEx", "Ptr", hHighResDC, "Int", centerX, "Int", 0, "Ptr", 0)
                    DllCall("LineTo", "Ptr", hHighResDC, "Int", centerX, "Int", previewHeight * 4)
                    DllCall("MoveToEx", "Ptr", hHighResDC, "Int", 0, "Int", centerY, "Ptr", 0)
                    DllCall("LineTo", "Ptr", hHighResDC, "Int", previewWidth * 4, "Int", centerY)
                    if this.HighlightCenter
                    {
                        hInnerCrosshairPen := DllCall("CreatePen", "Int", 0, "Int", Round(this.CrosshairWidth * dpiScale) * 4, "UInt", this.HighlightColor & 0xFFFFFF, "Ptr")
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
                    if Mod(captureSize, 2) == 0
                        centerIndex := captureSize // 2 + 1
                    else
                        centerIndex := captureSize // 2 + (captureSize & 1)

                    ; Draw grid
                    hGridPen := DllCall("CreatePen", "Int", 0, "Int", Round(this.GridWidth * dpiScale) * 4, "UInt", this.GridColor & 0xFFFFFF, "Ptr")
                    DllCall("SelectObject", "Ptr", hHighResDC, "Ptr", hGridPen)

                    Loop captureSize + 1
                    {
                        x := (A_Index - 1) * scaledZoomFactor * 4
                        DllCall("MoveToEx", "Ptr", hHighResDC, "Int", x, "Int", 0, "Ptr", 0)
                        DllCall("LineTo", "Ptr", hHighResDC, "Int", x, "Int", previewHeight * 4)
                        DllCall("MoveToEx", "Ptr", hHighResDC, "Int", 0, "Int", x, "Ptr", 0)
                        DllCall("LineTo", "Ptr", hHighResDC, "Int", previewWidth * 4, "Int", x)
                    }

                    if this.HighlightCenter
                    {
                        ; Highlight the center or lower-right of center square
                        hHighlightPen := DllCall("CreatePen", "Int", 0, "Int", Round(this.GridWidth * dpiScale) * 4, "UInt", this.HighlightColor & 0xFFFFFF, "Ptr")
                        DllCall("SelectObject", "Ptr", hHighResDC, "Ptr", hHighlightPen)
                        DllCall("MoveToEx", "Ptr", hHighResDC, "Int", (centerIndex - 1) * scaledZoomFactor * 4, "Int", (centerIndex - 1) * scaledZoomFactor * 4, "Ptr", 0)
                        DllCall("LineTo", "Ptr", hHighResDC, "Int", centerIndex * scaledZoomFactor * 4, "Int", (centerIndex - 1) * scaledZoomFactor * 4)
                        DllCall("LineTo", "Ptr", hHighResDC, "Int", centerIndex * scaledZoomFactor * 4, "Int", centerIndex * scaledZoomFactor * 4)
                        DllCall("LineTo", "Ptr", hHighResDC, "Int", (centerIndex - 1) * scaledZoomFactor * 4, "Int", centerIndex * scaledZoomFactor * 4)
                        DllCall("LineTo", "Ptr", hHighResDC, "Int", (centerIndex - 1) * scaledZoomFactor * 4, "Int", (centerIndex - 1) * scaledZoomFactor * 4)
                        DllCall("DeleteObject", "Ptr", hHighlightPen)
                    }

                    DllCall("DeleteObject", "Ptr", hGridPen)
                }
                else if this.HighlightCenter
                {
                    ; Draw a dot in the center
                    centerX := Round(previewWidth * 2) + offset
                    centerY := Round(previewHeight * 2) + offset
                    dotSize := Round(4 * dpiScale) * this.CenterDotRadius
                    hDotBrush := DllCall("CreateSolidBrush", "UInt", this.HighlightColor & 0xFFFFFF, "Ptr")
                    DllCall("SelectObject", "Ptr", hHighResDC, "Ptr", hDotBrush)
                    DllCall("Ellipse", "Ptr", hHighResDC, "Int", centerX - Round(dotSize * dpiScale), "Int", centerY - Round(dotSize * dpiScale), "Int", centerX + Round(dotSize * dpiScale), "Int", centerY + Round(dotSize * dpiScale))
                    DllCall("DeleteObject", "Ptr", hDotBrush)
                }

                ; Draw border
                hBorderPen := DllCall("CreatePen", "Int", 0, "Int", this.BorderWidth * 4, "UInt", this.BorderColor & 0xFFFFFF, "Ptr")
                DllCall("SelectObject", "Ptr", hHighResDC, "Ptr", hBorderPen)
                DllCall("MoveToEx", "Ptr", hHighResDC, "Int", 0, "Int", 0, "Ptr", 0)
                DllCall("LineTo", "Ptr", hHighResDC, "Int", previewWidth * 4, "Int", 0)
                DllCall("LineTo", "Ptr", hHighResDC, "Int", previewWidth * 4, "Int", totalHeight * 4)
                DllCall("LineTo", "Ptr", hHighResDC, "Int", 0, "Int", totalHeight * 4)
                DllCall("LineTo", "Ptr", hHighResDC, "Int", 0, "Int", 0)

                ; Draw separator line
                DllCall("MoveToEx", "Ptr", hHighResDC, "Int", 0, "Int", previewHeight * 4, "Ptr", 0)
                DllCall("LineTo", "Ptr", hHighResDC, "Int", previewWidth * 4, "Int", previewHeight * 4)
                DllCall("DeleteObject", "Ptr", hBorderPen)

                ; Create preview DC and scale down from high-res DC
                hPreviewDC := DllCall("CreateCompatibleDC", "Ptr", hDC, "Ptr")
                hPreviewBitmap := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", previewWidth, "Int", totalHeight, "Ptr")
                DllCall("SelectObject", "Ptr", hPreviewDC, "Ptr", hPreviewBitmap)
                DllCall("SetStretchBltMode", "Ptr", hPreviewDC, "Int", 4)
                DllCall("StretchBlt", "Ptr", hPreviewDC, "Int", 0, "Int", 0, "Int", previewWidth, "Int", totalHeight, "Ptr", hHighResDC, "Int", 0, "Int", 0, "Int", previewWidth * 4, "Int", totalHeight * 4, "UInt", 0x00CC0020)

                ; Update preview GUI
                hPreviewHWND := WinExist("A")
                DllCall("UpdateLayeredWindow", "Ptr", hPreviewHWND, "Ptr", 0, "Ptr", 0, "Int64*", previewWidth | (totalHeight << 32), "Ptr", hPreviewDC, "Int64*", 0, "UInt", 0, "UInt*", 0xFF << 16, "UInt", 2)

                ; Clean up
                DllCall("DeleteObject", "Ptr", hFont)
                DllCall("DeleteDC", "Ptr", hPreviewDC)
                DllCall("DeleteObject", "Ptr", hPreviewBitmap)
                DllCall("DeleteDC", "Ptr", hHighResDC)
                DllCall("DeleteObject", "Ptr", hHighResBitmap)
                DllCall("DeleteDC", "Ptr", hMemDC)
                DllCall("DeleteObject", "Ptr", hBitmap)
                DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)

                if (this.Callback != 0) and (this.Callback is Func)
                    this.Callback.Call(this.Color)
            }
        }

        CoordMode "Mouse", "Screen"
        CoordMode "Pixel", "Screen"
        Suspend(True)
        Hotkey("*LButton", BlockLButton, "On S")

        anchored := False, frozen := False, outType := "", anchoredX := 0, anchoredY := 0, colorSet := 0, textHeight := 0
        this.Color := {}
        zoomFactor     := this.DefaultZoomFactor
        captureSize    := this.DefaultCaptureSize
        previewXOffset := Round(captureSize / 2) + this.BorderWidth + 1
        previewYOffset := Round(captureSize / 2) + this.BorderWidth + 1

        previewGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80000 -DPIScale")
        previewGui.Show()
        SetTimer(CaptureAndPreview, this.UpdateInterval)

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
            MouseGetPos(&mouseX, &mouseY)

            if (this.TargetHWND != 0) and WinExist("ahk_id " this.TargetHWND)
            {
                mouseX := Max(confineLeft, Min(mouseX, confineRight))
                mouseY := Max(confineTop, Min(mouseY, confineBottom))
            }

            if anchored
            {
                previewGui.Move(anchoredX, anchoredY)
            }
            else
            {
                previewWidth  := captureSize * zoomFactor + this.BorderWidth * 2
                previewHeight := captureSize * zoomFactor + this.BorderWidth * 2 + textHeight

                newX := mouseX + previewXOffset
                newY := mouseY + previewYOffset

                monitorCount := MonitorGetCount()
                dpiScale := GetDpiScale(previewGui.Hwnd)
                Loop monitorCount
                {
                    MonitorGet(A_Index, &left, &top, &right, &bottom)

                    if (mouseX >= left && mouseX < right && mouseY >= top && mouseY < bottom)
                    {
                        ; Apply DPI scaling to preview dimensions
                        scaledPreviewWidth := previewWidth * dpiScale
                        scaledPreviewHeight := previewHeight * dpiScale

                        ; Adjust for right edge
                        if (newX + scaledPreviewWidth > right)
                            newX := mouseX - previewXOffset * dpiScale - scaledPreviewWidth

                        ; Adjust for bottom edge, including taskbar
                        if (newY + scaledPreviewHeight > bottom)
                            newY := mouseY - previewYOffset * dpiScale - scaledPreviewHeight

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
                anchored := !anchored
                if anchored
                {
                    anchoredX := mouseX + previewXOffset
                    anchoredY := mouseY + previewYOffset
                }

                if !KeyWait("a") or !KeyWait("NumpadDot")
                    continue
            }

            ; "M" cycles between view modes (grid, crosshair, none)
            if GetKeyState("m", "P")
            {
                this.ViewModes := [ "grid", "crosshair", "none" ]
                index := 0

                for mode in this.ViewModes
                    if (mode == this.ViewMode)
                        index := A_Index

                if index == 0
                {
                    this.ViewMode := "none"
                    index := 3
                }

                this.ViewMode := this.ViewModes[Mod(index, this.ViewModes.Length) + 1]
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
                captureSize := Max(1, --captureSize)

                previewXOffset := Round(captureSize / 2) + this.BorderWidth + 1
                previewYOffset := Round(captureSize / 2) + this.BorderWidth + 1

                if !KeyWait("-") or !KeyWait("NumpadSub")
                    continue
            }

            ; "=" or "NumpadAdd" increases capture size
            if GetKeyState("=", "P") or GetKeyState("NumpadAdd", "P")
            {
                captureSize := ++captureSize

                previewXOffset := Round(captureSize / 2) + this.BorderWidth + 1
                previewYOffset := Round(captureSize / 2) + this.BorderWidth + 1

                if !KeyWait("=") or !KeyWait("NumpadAdd")
                    continue
            }

            ; "[" or "NumpadDiv" decreases zoom factor
            if GetKeyState("[", "P") or GetKeyState("NumpadDiv", "P")
            {
                zoomFactor := Max(1, --zoomFactor)

                if !KeyWait("[") or !KeyWait("NumpadDiv")
                    continue
            }

            ; "]" or "NumpadMult" increases zoom factor
            if GetKeyState("]", "P") or GetKeyState("NumpadMult", "P")
            {
                zoomFactor := ++zoomFactor
                if !KeyWait("]") or !KeyWait("NumpadMult")
                    continue
            }

            ; "0" or "Numpad0" resets zoom and capture size
            if GetKeyState("0", "P") or GetKeyState("Numpad0", "P")
            {
                zoomFactor := this.DefaultZoomFactor
                captureSize := this.DefaultCaptureSize

                previewXOffset := Round(captureSize / 2) + this.BorderWidth + 1
                previewYOffset := Round(captureSize / 2) + this.BorderWidth + 1

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

        if (clip == True) and ((outType == "HEX") or (outType == "RGB"))
            A_Clipboard := (outType == "HEX" ? this.Color.Hex.Full : this.Color.RGB.Full)

        ; Cleanup
        SetTimer(CaptureAndPreview, 0)  ; Turn off the timer
        DllCall("SystemParametersInfo", "UInt", 0x57, "UInt", 0, "Ptr", 0, "UInt", 0)  ; Reset cursor
        DllCall("DestroyCursor", "Ptr", hCross)
        Sleep(50)
        Hotkey("*LButton", "Off")
        Suspend(False)

        previewGui.Destroy()
        try DllCall("SetThreadDpiAwarenessContext", "ptr", dpiContext, "ptr")

        if (this.TargetHWND != 0) and WinExist("ahk_id " this.TargetHWND)
            DllCall("ClipCursor", "Ptr", 0)

        this.Color := (outType == "Exit" ? startColor : this.Color)
        this.Callback.Call(this.Color)

        return (outType == "Exit" ? False : this.Color)
    }
}

/** Place a ";" at the beginning of this line to test the color picker
#c::
{
    mainWindow := Gui()
    mainWindow.MarginX := 5
    mainWindow.MarginY := 5
    mainWindow.SetFont("s8", "Lucida Console")
    mainWindow.Show("w310 h460")
    colorWheel := mainWindow.AddPicture("w300 h-1 +Border", "colorWheel.jpg")
    colorBox := MainWindow.AddText("x10 y+10 w290 h64 +BackgroundBlack", "")
    hexLabel := mainWindow.AddText("x10 y+10 w140", "Hex: #000000")
    rgbLabel := mainWindow.AddText("x160 yp+0 w140", "RGB: 0, 0, 0")
    hex_r := mainWindow.AddText("x10 y+5 w140", "R: 0x00")
    rgb_r := mainWindow.AddText("x160 yp+0 w140", "R: 0")
    hex_g := mainWindow.AddText("x10 y+5 w140", "G: 0x00")
    rgb_g := mainWindow.AddText("x160 yp+0 w140", "G: 0")
    hex_b := mainWindow.AddText("x10 y+5 w140", "B: 0x00")
    rgb_b := mainWindow.AddText("x160 yp+0 w140", "B: 0")

    picker := ColorPicker(False, ControlGetHwnd(colorWheel), UpdateColors)
    picker.FontName := "Papyrus"
    picker.FontSize := 24
    picker.HexFullFormatString := "0x{1:s}{2:s}{3:s}"
    picker.HexPartFormatString := "{1:s}"
    picker.HighlightCenter := True

    colorWheel.OnEvent("Click", (*) => picker.Start())

    _color := {}

    UpdateColors(color)
    {
        picker.TextFGColors[1] := "0x" color.Hex.B . color.Hex.G . color.Hex.R
        picker.TextFGColors[2] := "0x" color.Hex.B . color.Hex.G . color.Hex.R

        colorBox.Opt("+Redraw +Background" color.Hex.Full)

        hexLabel.Text := "Hex: " color.Hex.Full
        hex_r.Text := "R: " color.Hex.R
        hex_g.Text := "G: " color.Hex.G
        hex_b.Text := "B: " color.Hex.B

        rgbLabel.Text := "RGB: " color.RGB.Full
        rgb_r.Text := "R: " String(color.RGB.R)
        rgb_g.Text := "G: " String(color.RGB.G)
        rgb_b.Text := "B: " String(color.RGB.B)

        hexLabel.Opt("C" color.Hex.Full)
        hex_r.Opt("C" color.Hex.R . "0000")
        hex_g.Opt("C00" color.Hex.G . "00")
        hex_b.Opt("C0000" color.Hex.B)

        rgbLabel.Opt("C" color.Hex.Full)
        rgb_r.Opt("C" color.Hex.R . "0000")
        rgb_g.Opt("C00" color.Hex.G . "00")
        rgb_b.Opt("C0000" color.Hex.B)
    }
}