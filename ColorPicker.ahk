#Requires AutoHotkey v2.0
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
 * ; Structure ob returned object:
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
    fontName       := "Maple Mono"
    fontSize       := 16
    updateInterval := 16         ; The interval at which the preview will update, in milliseconds. 16ms = ~60 updates / second.
    textFGColor    := 0x000000   ; 0xBBGGRR Black Text Foreground
    textBGColor    := 0xFFFFFF   ; 0xBBGGRR White Text Background
    borderColor    := 0xFFFF0000 ; 0xAABBGGRR Blue Border
    crosshairColor := 0xFF0000FF ; 0xAABBGGRR Red Crosshair
    previewXOffset := 10         ; Controls the positioning of the window relative to the cursor (To Upper-Left Window Corner)
    previewYOffset := 10         ;
    textPadding    := 6          ; The padding added above and below the preview Hex String, in pixels (half above, half below)
    captureSize    := 9          ; The size of area you want to capture around the cursor in pixels (N by N square, works best with odd numbers)
    zoomFactor     := 11         ; Length of preview window sides in pixels = captureSize * zoomFactor. (9 * 11 = 99x99 pixel preview window)

    ; Output format strings
    RGBFullFormatString := "{1:u}, {2:u}, {3:u}" ; Format(RGBFullFormatString, "0x" r, "0x" g, "0x" b) (Switch to {3:i}, {2:i}, {1:i} for BGR)
    RGBPartFormatString := "{1:u}"               ; Format(RGBPartFormatString, "0x" r)
    HexFullFormatString := "#{1:s}{2:s}{3:s}"    ; Format(HexFullFormatString, r, g, b) (This will also change what is displayed in the preview gui)
    HexPartFormatString := "0x{1:s}"             ; Format(HexPartFormatString, r)

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
        previewGui.Show("x" cursorX + previewXOffset " y" cursorY + previewYOffset)

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
        previewWidth := width * zoomFactor
        previewHeight := height * zoomFactor
        hPreviewDC := DllCall("CreateCompatibleDC", "Ptr", hDC, "Ptr")

        ; Prepare to draw text, this has to be done first to calculate it's height
        LOGFONT := Buffer(92, 0)
        NumPut("Int", fontSize, LOGFONT, 0)
        StrPut(fontName, LOGFONT.Ptr + 28, 32, "UTF-16")
        hFont := DllCall("CreateFontIndirect", "Ptr", LOGFONT, "Ptr")
        DllCall("SelectObject", "Ptr", hPreviewDC, "Ptr", hFont)
        DllCall("SetTextColor", "Ptr", hPreviewDC, "UInt", textFGColor)  ; Black text
        DllCall("SetBkColor", "Ptr", hPreviewDC, "UInt", textBGColor)  ; White background
        size := Buffer(8)
        DllCall("GetTextExtentPoint32", "Ptr", hPreviewDC, "Str", "Ay", "Int", 2, "Ptr", size)
        textHeight := NumGet(size, 4, "Int") + textPadding

        ; Conclude size calculations, create preview.
        totalHeight := previewHeight + textHeight
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

        ; Draw text
        textWidth := DllCall("GetTextExtentPoint32", "Ptr", hPreviewDC, "Str", hexColor, "Int", StrLen(hexColor), "Ptr", rect)
        textX := (previewWidth - NumGet(rect, 0, "Int")) // 2
        textY := previewHeight + (textHeight - fontSize) // 2
        DllCall("TextOut", "Ptr", hPreviewDC, "Int", textX, "Int", textY, "Str", hexColor, "Int", StrLen(hexColor))

        ; Draw crosshair
        hCrosshairPen := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", crosshairColor & 0xFFFFFF, "Ptr")
        DllCall("SelectObject", "Ptr", hPreviewDC, "Ptr", hCrosshairPen)
        DllCall("MoveToEx", "Ptr", hPreviewDC, "Int", previewWidth // 2, "Int", 0, "Ptr", 0)
        DllCall("LineTo", "Ptr", hPreviewDC, "Int", previewWidth // 2, "Int", previewHeight)
        DllCall("MoveToEx", "Ptr", hPreviewDC, "Int", 0, "Int", previewHeight // 2, "Ptr", 0)
        DllCall("LineTo", "Ptr", hPreviewDC, "Int", previewWidth, "Int", previewHeight // 2)

        ; Draw border
        hBorderPen := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", borderColor & 0xFFFFFF, "Ptr")
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

        ; Update preview GUI
        hPreviewHWND := WinExist("A")
        DllCall("UpdateLayeredWindow"
            , "Ptr", hPreviewHWND
            , "Ptr", 0
            , "Ptr", 0
            , "Int64*", previewWidth | (totalHeight << 32)
            , "Ptr", hPreviewDC
            , "Int64*", 0
            , "UInt", 0
            , "UInt*", 0xFF << 16
            , "UInt", 2)

        ; Clean up
        DllCall("DeleteObject", "Ptr", hFont)
        DllCall("DeleteObject", "Ptr", hBrush)
        DllCall("DeleteObject", "Ptr", hBorderPen)
        DllCall("DeleteObject", "Ptr", hCrosshairPen)
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

    hexColor := "", outType := "", _c := { R: 0, G: 0, B: 0 }
    previewGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80000")

    ; Set the cursor to crosshair
    hCross := DllCall("LoadCursor", "Ptr", 0, "Ptr", 32515)
    for cursorId in [32512, 32513, 32514, 32515, 32516, 32631, 32640, 32641, 32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650, 32651]
        DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", hCross, "UInt", 2, "Int", 0, "Int", 0, "UInt", 0), "UInt", cursorId)

    SetTimer(CaptureAndPreview, updateInterval)
    ; Main loop
    while (True)
    {
        if GetKeyState("LButton", "P")
        {
            if GetKeyState("Shift", "P")
                outType := "RGB"
            else
                outType := "HEX"
            break
        }

        if GetKeyState("Escape", "P")
        {
            outType := "Exit"
            break
        }

        Sleep(10)

        MouseGetPos(&mouseX, &mouseY)
        previewGui.Move(mouseX + previewXOffset, mouseY + previewYOffset)  ; Offset from cursor
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

#c::
{
    _color := ColorPicker()

    if _color
    {
        ; RGB
        rgb_r    := _color.RGB.R
        rgb_g    := _color.RGB.G
        rgb_b    := _color.RGB.B
        rgb_full := _color.RGB.Full

        ; HEX
        hex_r    := _color.Hex.R
        hex_g    := _color.Hex.G
        hex_b    := _color.Hex.B
        hex_full := _color.Hex.Full

        MsgBox("RGB: " rgb_full "`nR: " rgb_r "`nG: " rgb_g "`nB: " rgb_b "`n`nHex: " hex_full "`nR: " hex_r "`nG: " hex_g "`nB: " hex_b "`n`nClipboard: " A_Clipboard, "Selected Color Information")
    }
    else
    {
        MsgBox("ColorPicker function Exited by user.")
    }
}
