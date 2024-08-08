#Requires AutoHotKey v2.0
/**
 * Enables a color selector and shows a configurable preview of the area around the mouse cursor.
 * The preview follows the mouse and updates in real-time.
 * Returns an Object with the Keys "Hex" and "RGB", each with the individual color parts and the full color value.
 *
 * `LButton` to copy the Hex value to the clipboard
 *
 * `Shift+LButton` Click to copy the RGB value to the clipboard
 *
 * `Escape` to exit
 *
 * @param {Boolean} clip Whether or not to copy the color value to the clipboard.
 * @returns {Object | False} Returns an object containing the color values if successful, false otherwise.
 * ```ahk2
 * ; Structure of the returned color object:
 * return { 
 *       RGB: {
 *           R: Format(RGBPartFormatString, "0x" _c.R),
 *           G: Format(RGBPartFormatString, "0x" _c.G),
 *           B: Format(RGBPartFormatString, "0x" _c.B),
 *           Full: Format(RGBFullFormatString, "0x" _c.R, "0x" _c.G, "0x" _c.B)
 *       },
 *       Hex: {
 *           R: Format(HexPartFormatString, _c.R),
 *           G: Format(HexPartFormatString, _c.G),
 *           B: Format(HexPartFormatString, _c.B),
 *           Full: Format(HexFullFormatString, _c.R, _c.G, _c.B)
 *       }
 *    }
 * ```
 */
ColorPicker(clip := True)
{
    ; Configuration variables
    fontName        := "Consolas"   ; Can be any font installed on your system
    fontSize        := 16           ; Font size for the preview text
    viewMode        := "grid"       ; Can be "crosshair", "grid", any other value will result in no overlay
    updateInterval  := 16           ; The interval at which the preview will update, in milliseconds. 16ms = ~60 updates / second.
    textFGColor     := 0x000000     ; 0xBBGGRR Text Foreground
    textBGColor     := 0xFFFFFF     ; 0xBBGGRR Text Background
    borderColor     := 0xFFFFFFFF   ; 0xAABBGGRR Border Color
    crosshairColor  := 0xFFFFFFFF   ; 0xAABBGGRR Crosshair Color
    gridColor       := 0xFF000000   ; 0xAABBGGRR Grid Color
    highlightColor  := 0xFFFFFFFF   ; 0xAABBGGRR Highlight Color for selected grid square
    highlightCenter := True         ; If True, highlights the pixel that the color is copied from.
    borderWidth     := 1            ; Thickness of preview border, in pixels.
    crosshairWidth  := 1            ; Thickness of crosshair lines, in pixels.
    gridWidth       := 1            ; Thickness of grid lines, in pixels.
    previewXOffset  := 10           ; Controls the positioning of the window relative to the cursor (To Upper-Left Window Corner)
    previewYOffset  := 10           ;
    textPadding     := 6            ; The padding added above and below the preview Hex String, in pixels (half above, half below)
    captureSize     := 19           ; The size of area you want to capture around the cursor in pixels (N by N square, works best with odd numbers)
    zoomFactor      := 10           ; Length of preview window sides in pixels = captureSize * zoomFactor. (9 * 11 = 99x99 pixel preview window)
    anchored        := False        ; If True, the preview window will be anchored in place, otherwise it will follow the cursor.

    ; Output format strings. These control how the values in the return object are formatted. The HexFullFormatString also controls what is displayed in the preview gui.
    RGBFullFormatString := "{1:u}, {2:u}, {3:u}" ; Format(RGBFullFormatString, "0x" r, "0x" g, "0x" b) (Switch to {3:i}, {2:i}, {1:i} for BGR)
    RGBPartFormatString := "{1:u}"               ; Format(RGBPartFormatString, "0x" r)
    HexFullFormatString := "#{1:s}{2:s}{3:s}"    ; Format(HexFullFormatString, r, g, b) (Switch to "#{3:s}{2:s}{1:s}" for BGR)
    HexPartFormatString := "0x{1:s}"             ; Format(HexPartFormatString, r)

    GetDpiScale()
    {
        hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
        dpi := DllCall("GetDeviceCaps", "Ptr", hDC, "Int", 88, "Int")
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
        return dpi / 96
    }

    BlockLButton(*)
    {
        KeyWait("LButton", "D")
        return
    }

    CaptureAndPreview(*)
    {
        ; Get cursor position
        CoordMode "Mouse", "Screen"
        CoordMode "Pixel", "Screen"
        MouseGetPos(&cursorX, &cursorY)
        previewGui.Show()

        ; Calculate capture region
        halfSize := (captureSize - 1) // 2
        left := cursorX - halfSize
        top := cursorY - halfSize
        width := captureSize
        height := captureSize

        ; Capture screen region
        hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
        hMemDC := DllCall("CreateCompatibleDC", "Ptr", hDC, "Ptr")
        hBitmap := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", width, "Int", height, "Ptr")
        DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hBitmap)
        DllCall("BitBlt", "Ptr", hMemDC, "Int", 0, "Int", 0, "Int", width, "Int", height, "Ptr", hDC, "Int", left, "Int", top, "UInt", 0x00CC0020)

        ; Get color of central pixel
        centralX := width // 2
        centralY := height // 2
        centralColor := DllCall("GetPixel", "Ptr", hMemDC, "Int", centralX, "Int", centralY, "UInt")
        hexColor := Format("#{:06X}", centralColor & 0xFFFFFF)
        _c := { B: SubStr(hexColor, 2, 2), G: SubStr(hexColor, 4, 2), R: SubStr(hexColor, 6, 2) }
        hexColor := Format(HexFullFormatString, _c.R, _c.G, _c.B)

        ; Calculate preview size
        previewWidth := Round(width * zoomFactor * dpiScale)
        previewHeight := Round(height * zoomFactor * dpiScale)
        hPreviewDC := DllCall("CreateCompatibleDC", "Ptr", hDC, "Ptr")

        ; Prepare to draw text, this has to be done first to calculate it's height
        LOGFONT := Buffer(92, 0)
        NumPut("Int", fontSize, LOGFONT, 0)
        StrPut(fontName, LOGFONT.Ptr + 28, 32, "UTF-16")
        hFont := DllCall("CreateFontIndirect", "Ptr", LOGFONT, "Ptr")
        DllCall("SelectObject", "Ptr", hPreviewDC, "Ptr", hFont)
        DllCall("SetTextColor", "Ptr", hPreviewDC, "UInt", textFGColor)  ; Black text
        DllCall("SetBkColor", "Ptr", hPreviewDC, "UInt", textBGColor)  ; White background
        DllCall("DeleteObject", "Ptr", hFont)
        size := Buffer(8)
        DllCall("GetTextExtentPoint32", "Ptr", hPreviewDC, "Str", "Ay", "Int", 2, "Ptr", size)
        textHeight := NumGet(size, 4, "Int") + textPadding

        ; Conclude size calculations, create preview.
        totalHeight := Round((previewHeight + textHeight) * dpiScale)
        hPreviewBitmap := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", previewWidth, "Int", totalHeight, "Ptr")
        DllCall("SelectObject", "Ptr", hPreviewDC, "Ptr", hPreviewBitmap)
        DllCall("StretchBlt", "Ptr", hPreviewDC, "Int", 0, "Int", 0, "Int", previewWidth, "Int", previewHeight, "Ptr", hMemDC, "Int", 0, "Int", 0, "Int", width, "Int", height, "UInt", 0x00CC0020)

        ; Draw background rectangle
        hBrush := DllCall("CreateSolidBrush", "UInt", textBGColor, "Ptr")
        rect := Buffer(16, 0)
        NumPut("Int", 0, rect, 0)
        NumPut("Int", previewHeight, rect, 4)
        NumPut("Int", previewWidth, rect, 8)
        NumPut("Int", totalHeight, rect, 12)
        DllCall("FillRect", "Ptr", hPreviewDC, "Ptr", rect, "Ptr", hBrush)
        DllCall("DeleteObject", "Ptr", hBrush)

        ; Draw text
        textWidth := DllCall("GetTextExtentPoint32", "Ptr", hPreviewDC, "Str", hexColor, "Int", StrLen(hexColor), "Ptr", rect)
        textX := (previewWidth - NumGet(rect, 0, "Int")) // 2
        textY := previewHeight + (textHeight - fontSize) // 2
        DllCall("TextOut", "Ptr", hPreviewDC, "Int", textX, "Int", textY, "Str", hexColor, "Int", StrLen(hexColor))

        ; Calculate the offset based on captureSize
        offset := (Mod(captureSize, 2) == 0) ? Round(zoomFactor / 2 * dpiScale) : 0

        if (viewMode == "crosshair")
        {
            centerX := Round(previewWidth / 2) + offset
            centerY := Round(previewHeight / 2) + offset
            halfZoom := Round(zoomFactor / 2 * dpiScale)

            hCrosshairPen := DllCall("CreatePen", "Int", 0, "Int", Round(crosshairWidth * dpiScale), "UInt", crosshairColor & 0xFFFFFF, "Ptr")
            DllCall("SelectObject", "Ptr", hPreviewDC, "Ptr", hCrosshairPen)
            DllCall("MoveToEx", "Ptr", hPreviewDC, "Int", centerX, "Int", 0, "Ptr", 0)
            DllCall("LineTo", "Ptr", hPreviewDC, "Int", centerX, "Int", previewHeight)
            DllCall("MoveToEx", "Ptr", hPreviewDC, "Int", 0, "Int", centerY, "Ptr", 0)
            DllCall("LineTo", "Ptr", hPreviewDC, "Int", previewWidth, "Int", centerY)

            if highlightCenter
            {
                hInnerCrosshairPen := DllCall("CreatePen", "Int", 0, "Int", Round(crosshairWidth * dpiScale), "UInt", highlightColor & 0xFFFFFF, "Ptr")
                DllCall("SelectObject", "Ptr", hPreviewDC, "Ptr", hInnerCrosshairPen)
                DllCall("MoveToEx", "Ptr", hPreviewDC, "Int", centerX, "Int", centerY - halfZoom, "Ptr", 0)
                DllCall("LineTo", "Ptr", hPreviewDC, "Int", centerX, "Int", centerY + halfZoom)
                DllCall("MoveToEx", "Ptr", hPreviewDC, "Int", centerX - halfZoom, "Int", centerY, "Ptr", 0)
                DllCall("LineTo", "Ptr", hPreviewDC, "Int", centerX + halfZoom, "Int", centerY)
                DllCall("DeleteObject", "Ptr", hInnerCrosshairPen)
            }
        }
        else if (viewMode == "grid")
        {
            ; Draw grid
            hGridPen := DllCall("CreatePen", "Int", 0, "Int", gridWidth, "UInt", gridColor & 0xFFFFFF, "Ptr")
            DllCall("SelectObject", "Ptr", hPreviewDC, "Ptr", hGridPen)

            ; Calculate the center square
            if Mod(captureSize, 2) == 0
                centerIndex := captureSize // 2 + 1
            else
                centerIndex := captureSize // 2 + (captureSize & 1)

            Loop captureSize
            {
                x := (A_Index - 1) * zoomFactor
                DllCall("MoveToEx", "Ptr", hPreviewDC, "Int", x, "Int", 0, "Ptr", 0)
                DllCall("LineTo", "Ptr", hPreviewDC, "Int", x, "Int", previewHeight)
                DllCall("MoveToEx", "Ptr", hPreviewDC, "Int", 0, "Int", x, "Ptr", 0)
                DllCall("LineTo", "Ptr", hPreviewDC, "Int", previewWidth, "Int", x)
            }

            if highlightCenter
            {
                ; Highlight the center or lower-right of center square
                hHighlightPen := DllCall("CreatePen", "Int", 0, "Int", gridWidth, "UInt", highlightColor & 0xFFFFFF, "Ptr") ; Red color
                DllCall("SelectObject", "Ptr", hPreviewDC, "Ptr", hHighlightPen)
                DllCall("MoveToEx", "Ptr", hPreviewDC, "Int", (centerIndex - 1) * zoomFactor, "Int", (centerIndex - 1) * zoomFactor, "Ptr", 0)
                DllCall("LineTo", "Ptr", hPreviewDC, "Int", centerIndex * zoomFactor, "Int", (centerIndex - 1) * zoomFactor)
                DllCall("LineTo", "Ptr", hPreviewDC, "Int", centerIndex * zoomFactor, "Int", centerIndex * zoomFactor)
                DllCall("LineTo", "Ptr", hPreviewDC, "Int", (centerIndex - 1) * zoomFactor, "Int", centerIndex * zoomFactor)
                DllCall("LineTo", "Ptr", hPreviewDC, "Int", (centerIndex - 1) * zoomFactor, "Int", (centerIndex - 1) * zoomFactor)
                DllCall("DeleteObject", "Ptr", hHighlightPen)
                DllCall("SelectObject", "Ptr", hPreviewDC, "Ptr", hGridPen)
            }

            DllCall("DeleteObject", "Ptr", hGridPen)
        }
        else if highlightCenter
        {
            ; Draw a dot in the center
            centerX := Round(previewWidth / 2) + offset
            centerY := Round(previewHeight / 2) + offset
            dotSize := Round(2 * dpiScale)

            hDotBrush := DllCall("CreateSolidBrush", "UInt", highlightColor & 0xFFFFFF, "Ptr")
            DllCall("SelectObject", "Ptr", hPreviewDC, "Ptr", hDotBrush)
            DllCall("Ellipse", "Ptr", hPreviewDC, "Int", centerX - dotSize, "Int", centerY - dotSize, "Int", centerX + dotSize, "Int", centerY + dotSize)
            DllCall("DeleteObject", "Ptr", hDotBrush)
        }

        ; Draw border
        hBorderPen := DllCall("CreatePen", "Int", 0, "Int", borderWidth, "UInt", borderColor & 0xFFFFFF, "Ptr")
        DllCall("SelectObject", "Ptr", hPreviewDC, "Ptr", hBorderPen)
        DllCall("MoveToEx", "Ptr", hPreviewDC, "Int", 0, "Int", 0, "Ptr", 0)
        DllCall("LineTo", "Ptr", hPreviewDC, "Int", previewWidth - 1, "Int", 0)
        DllCall("LineTo", "Ptr", hPreviewDC, "Int", previewWidth - 1, "Int", totalHeight - 1)
        DllCall("LineTo", "Ptr", hPreviewDC, "Int", 0, "Int", totalHeight - 1)
        DllCall("LineTo", "Ptr", hPreviewDC, "Int", 0, "Int", 0)

        ; Draw separator line
        DllCall("SelectObject", "Ptr", hPreviewDC, "Ptr", hBorderPen)
        DllCall("MoveToEx", "Ptr", hPreviewDC, "Int", 0, "Int", previewHeight, "Ptr", 0)
        DllCall("LineTo", "Ptr", hPreviewDC, "Int", previewWidth, "Int", previewHeight)
        DllCall("DeleteObject", "Ptr", hBorderPen)

        ; Update preview GUI
        hPreviewHWND := WinExist("A")
        DllCall("UpdateLayeredWindow", "Ptr", hPreviewHWND, "Ptr", 0, "Ptr", 0, "Int64*", previewWidth | (totalHeight << 32), "Ptr", hPreviewDC, "Int64*", 0, "UInt", 0, "UInt*", 0xFF << 16, "UInt", 2)
        ;DllCall("UpdateLayeredWindow", "Ptr", hPreviewHWND, "Ptr", 0, "Ptr", 0, "Int64*", previewWidth | (totalHeight << 32), "Ptr", hPreviewDC, "Int64*", 0, "UInt", 0, "UInt*", 0xFF << 16, "UInt", 2)

        ; Clean up
        DllCall("DeleteDC", "Ptr", hPreviewDC)
        DllCall("DeleteObject", "Ptr", hPreviewBitmap)
        DllCall("DeleteDC", "Ptr", hMemDC)
        DllCall("DeleteObject", "Ptr", hBitmap)
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
    }

    CoordMode "Mouse", "Screen"
    CoordMode "Pixel", "Screen"
    Suspend(True)
    Hotkey("*LButton", BlockLButton, "On S")

    hexColor := "", outType := "", anchoredX := 0, anchoredY := 0, _c := { R: 0, G: 0, B: 0 }
    previewGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80000 -DPIScale")
    dpiScale := GetDpiScale()

    SetTimer(CaptureAndPreview, updateInterval)

    ; Set the cursor to crosshair
    hCross := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32515)
    for cursorId in [32512, 32513, 32514, 32515, 32516, 32631, 32640, 32641, 32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650, 32651]
        DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", hCross, "UInt", 2, "Int", 0, "Int", 0, "UInt", 0), "UInt", cursorId)

    ; Main loop
    while (True)
    {
        MouseGetPos(&mouseX, &mouseY)
        if anchored
            previewGui.Move(anchoredX, anchoredY)
        else
            previewGui.Move(mouseX + previewXOffset, mouseY + previewYOffset)  ; Offset from cursor

        if GetKeyState("LButton", "P")
        {
            if GetKeyState("Shift", "P")
                outType := "RGB"
            else
                outType := "HEX"

            break
        }

        if GetKeyState("Escape", "P") or GetKeyState("q", "P")
        {
            outType := "Exit"
            break
        }

        if GetKeyState("a", "P")
        {
            anchored := !anchored
            if anchored
            {
                anchoredX := mouseX + previewXOffset
                anchoredy := mouseY + previewYOffset
            }

            KeyWait("a")
        }

        if GetKeyState("m", "P")
        {
            viewModes := [ "grid", "crosshair", "none" ]

            index := 0
            for mode in viewModes
                if (mode == viewMode)
                    index := A_Index

            if index == 0
            {
                viewMode := "none"
                index := 3
            }

            viewMode := viewModes[Mod(index, viewModes.Length) + 1]

            KeyWait("m")
        }

        if GetKeyState("h", "P")
        {
            highlightCenter := !highlightCenter
            KeyWait("h")
        }

        if GetKeyState("-", "P")
        {
            captureSize := Max(1, --captureSize)
            KeyWait("-")
        }

        if GetKeyState("=", "P")
        {
            captureSize := ++captureSize
            KeyWait("=")
        }

        if GetKeyState("[", "P")
        {
            zoomFactor := Max(1, --zoomFactor)
            KeyWait("[")
        }

        if GetKeyState("]", "P")
        {
            zoomFactor := ++zoomFactor
            KeyWait("]")
        }

        Sleep(10)
    }

    _color := {
        RGB: {
            R: Format(RGBPartFormatString, "0x" _c.R),
            G: Format(RGBPartFormatString, "0x" _c.G),
            B: Format(RGBPartFormatString, "0x" _c.B),
            Full: Format(RGBFullFormatString, "0x" _c.R, "0x" _c.G, "0x" _c.B)
        },
        Hex: {
            R: Format(HexPartFormatString, _c.R),
            G: Format(HexPartFormatString, _c.G),
            B: Format(HexPartFormatString, _c.B),
            Full: Format(HexFullFormatString, _c.R, _c.G, _c.B)
        }
    }

    if (clip == True) and ((outType == "HEX") or (outType == "RGB"))
        A_Clipboard := (outType == "HEX" ? _color.Hex.Full : _color.RGB.Full)

    ; Cleanup
    SetTimer(CaptureAndPreview, 0)  ; Turn off the timer
    DllCall("SystemParametersInfo", "UInt", 0x57, "UInt", 0, "Ptr", 0, "UInt", 0)  ; Reset cursor
    Sleep(50)
    Hotkey("*LButton", "Off")
    Suspend(False)
    previewGui.Destroy()

    return (outType == "Exit" ? False : _color)
}
