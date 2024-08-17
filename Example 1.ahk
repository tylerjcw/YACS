#Requires AutoHotkey v2.0

#requires AutoHotKey v2.0
#include ColorPicker.ahk

mainWindow := Gui( , "Color Converter")
mainWindow.Show("w500 h345")
mainWindow.SetFont("s8", "Lucida Console")

insText  := mainWindow.AddText("x10 y10 w480 Center", "Click below to select a color")
colorBox := MainWindow.AddText("x10 y+5 w480 h64 Center +BackgroundBlack", "")

; Hex & RGB
hexLabel := mainWindow.AddText("x10 y+10 w235", "Hex: #000000")
rgbLabel := mainWindow.AddText("x255 yp w235", "RGB: 0, 0, 0")
hexR := mainWindow.AddText("x10 y+5 w235", "R: 0")
rgbR := mainWindow.AddText("x255 yp w235", "R: 0")
hexG := mainWindow.AddText("x10 y+5 w235", "G: 0")
rgbG := mainWindow.AddText("x255 yp w235", "G: 0")
hexB := mainWindow.AddText("x10 y+5 w235", "B: 0")
rgbB := mainWindow.AddText("x255 yp w235", "B: 0")

; HSL & HWB
hslLabel := mainWindow.AddText("x10 y+10 w235", "HSL: hsl(0, 0%, 0%)")
hwbLabel := mainWindow.AddText("x255 yp w235", "HWB: hwb(0, 0%, 0%)")
hslH := mainWindow.AddText("x10 y+5 w235", "H: 0")
hwbH := mainWindow.AddText("x255 yp w235", "H: 0")
hslS := mainWindow.AddText("x10 y+5 w235", "S: 0%")
hwbW := mainWindow.AddText("x255 yp w235", "W: 0")
hslL := mainWindow.AddText("x10 y+5 w235", "L: 0%")
hwbB := mainWindow.AddText("x255 yp w235", "B: 0")

; CMYK & NCol
cmykLabel := mainWindow.AddText("x10 y+10 w235", "CMYK: cmyk(0%, 0%, 0%, 100%)")
ncolLabel := mainWindow.AddText("x255 yp w235", "Ncol: ncol(R0, 100%, 0%)")
cmykC := mainWindow.AddText("x10 y+5 w235", "C: 0%")
ncolH := mainWindow.AddText("x255 yp w235", "H: 0")
cmykM := mainWindow.AddText("x10 y+5 w235", "M: 0%")
ncolW := mainWindow.AddText("x255 yp w235", "W: 0%")
cmykY := mainWindow.AddText("x10 y+5 w235", "Y: 0%")
ncolB := mainWindow.AddText("x255 yp w155", "B: 0%")
cmykK := mainWindow.AddText("x10 y+5 w235", "K: 100%")

; ABGR and BGR
abgrLabel := mainWindow.AddText("x10 y+10 w235", "ABGR: FF000000")
bgrLabel := mainWindow.AddText("x255 yp w235", "BGR: 000000")

rgb    := Color(255, 66, 32)
hex    := Color("#FF4220")
hsl    := Color.FromHSL(9, 100, 56)
hwb    := Color.FromHWB(9, 13, 0)
cmyk   := Color.FromCMYK(0, 74, 87, 0)
ncol   := Color.FromNCol("R15", 13, 0)
MsgBox("This MsgBox shows the inaccuracies of the `"From*`" methods.`nAll of these were converted from the same color.`nResults will vary by color.`n`nFrom: rgb(255, 66, 32, 255)`n`nRGB: " rgb.Full "`nHex: " hex.Full "`nHSL: " hsl.Full "`nHWB: " hwb.Full "`nCMYK: " cmyk.Full "`nNcol: " ncol.Full, "Color.From*() Methods")

picker := ColorPicker(False)
picker.OnUpdate := UpdateColors
picker.OnExit   := ColorChosen
picker.FontName := "Consolas"
picker.FontSize := 24
picker.TextFGColors := [ Color("4F0110"), Color("6390DD") ]
picker.BorderColors := [ Color("0x4F0110"), Color("#6390DD") ]

colorBox.OnEvent("Click", (*) => picker.Start())

UpdateColors(colorObj)
{
    hex := colorObj.ToHex("{R}{G}{B}")
    colorBox.Opt("+Redraw +Background" hex.Full)
    picker.TextBGColor := colorObj
    picker.TextFGColor := colorObj.Invert()
}

ColorChosen(colorObj)
{
    ;RGB
    colorObj.RGBFormat := "{R}, {G}, {B}"
    rgbLabel.Text := "RGB: " colorObj.Full
    rgbR.Text := "R: " colorObj.R
    rgbG.Text := "G: " colorObj.G
    rgbB.Text := "B: " colorObj.B

    ; Hex
    hex := colorObj.ToHex("{R}{G}{B}")
    hexLabel.Text := "Hex: #" hex.Full
    hexR.Text := "R: " hex.R
    hexG.Text := "G: " hex.G
    hexB.Text := "B: " hex.B

    ; HSL
    hsl := colorObj.ToHSL("HSL: {H}, {S}%, {L}%")
    hslLabel.Text := hsl.Full
    hslH.Text := "H: " hsl.H
    hslS.Text := "S: " hsl.S "%"
    hslL.Text := "L: " hsl.L "%"

    ; HWB
    hwb := colorObj.ToHWB("HWB: {H}, {W}%, {B}%")
    hwbLabel.Text := hwb.Full
    hwbH.Text := "H: " hwb.H
    hwbW.Text := "W: " hwb.W "%"
    hwbB.Text := "B: " hwb.B "%"

    ; CMYK
    cmyk := colorObj.ToCMYK("CMYK: {C}%, {M}%, {Y}%, {K}%")
    cmykLabel.Text := cmyk.Full
    cmykC.Text := "C: " cmyk.C "%"
    cmykM.Text := "M: " cmyk.M "%"
    cmykY.Text := "Y: " cmyk.Y "%"
    cmykK.Text := "K: " cmyk.K "%"

    ; Ncol
    ncol := colorObj.ToNcol("NCol: {H}, {W}%, {B}%")
    ncolLabel.Text := ncol.Full
    ncolH.Text := "H: " ncol.h
    ncolW.Text := "W: " ncol.w "%"
    ncolB.Text := "B: " ncol.b "%"

    ; ABGR and BGR
    abgrLabel.Text := "ABGR: " Format("0x{1:02X}{2:02X}{3:02X}{4:02X}", colorObj.A, colorObj.B, colorObj.G, colorObj.R)
    bgrLabel.Text := "BGR: " Format("0x{1:02X}{2:02X}{3:02X}", colorObj.B, colorObj.G, colorObj.R)

    ; Update text colors
    for ctrl in [hexLabel, rgbLabel, hslLabel, hwbLabel, cmykLabel, ncolLabel, abgrLabel, bgrLabel]
        ctrl.Opt("C" hex.Full)
}

#1::mainWindow.Show("w500 h345")