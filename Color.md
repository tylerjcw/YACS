# Color Class Overview

## Introduction

The Color class is a comprehensive color manipulation and conversion utility for AutoHotkey v2.0. It provides a robust set of methods for creating, modifying, and converting colors between various color models including RGB, HEX, HSL, HWB, CMYK, and NCol.

## Properties

- `HexFormat`: The hexadecimal color code format for `Color.ToHex().Full`.
- `RGBFormat`: The RGB color code format for `Color.ToRGB().Full`.
- `HSLFormat`: The HSL color code format for `Color.ToHSL().Full`.
- `HWBFormat`: The HWB color code format for `Color.ToHWB().Full`.
- `CMYKFormat`: The CMYK color code format for `Color.ToCMYK().Full`.
- `NColFormat`: The NCol color code format for `Color.ToNCol().Full`.
- `XYZFormat`: The XYZ color code format for `Color.ToXYZ().Full`.
- `LabFormat`: The Lab color code format for `Color.ToLab().Full`.
- `YIQFormat`: The YIQ color code format for `Color.ToYIQ().Full`.

## Methods

### Constructor

- `__New(colorArgs*)`: Creates a new Color instance from various input formats.

### Conversion Methods

- `ToHex(formatString := "")`: Converts the stored color to Hexadecimal representation.
- `ToHSL(formatString := "")`: Converts the stored color to HSLA representation.
- `ToHWB(formatString := "")`: Converts the stored color to HWB representation.
- `ToCMYK(formatString := "")`: Converts the stored color to CMYK representation.
- `ToNCol(formatString := "")`: Converts the stored color to NCol representation.
- `ToXYZ(formatString := "")`: Converts the stored color to XYZ representation.
- `ToLab(formatString := "")`: Converts the stored color to Lab representation.
- `ToYIQ(formatString := "")`: Converts the stored color to YIQ representation.

### Color Manipulation Methods

- `Invert()`: Inverts the current color.
- `Grayscale()`: Returns the grayscale representation of the current color.
- `Sepia()`: Applies a sepia tone filter to the current color.
- `ShiftHue(degrees)`: Shifts the current color's hue.
- `ShiftSaturation(amount)`: Shifts the current color's saturation.
- `Saturate(percentage)`: Increases the current color's saturation.
- `Desaturate(percentage)`: Decreases the current color's saturation.
- `ShiftLightness(amount)`: Shifts the current color's lightness.
- `Lighten(percentage)`: Increases the current color's lightness.
- `Darken(percentage)`: Decreases the current color's lightness.
- `ShiftWhiteness(amount)`: Shifts the current color's whiteness.
- `ShiftBlackness(amount)`: Shifts the current color's blackness.
- `Complement()`: Returns the complementary color.
- `Mix(_color, weight := 50)`: Mixes the current color with another color.

### Color Analysis Methods

- `GetLuminance()`: Returns the luminance of the current color.
- `IsLight()`: Checks if the current color is light.
- `IsDark()`: Checks if the current color is dark.
- `GetContrast(_color)`: Gets the contrast ratio between the current color and another.

### Color Scheme Generation Methods

- `Analogous(angle := 30, count := 3)`: Generates analogous colors.
- `Triadic()`: Generates a Triadic color scheme.
- `Gradient(steps := 10, colors*)`: Produces a gradient from the current `Color` to an arbitrary number of colors. `steps` determines the number of steps in the gradient. `steps between colors := steps / colors.Length`.

## Static Methods

- `Random()`: Generates a random color.
- `FromRGB(colorArgs*)`: Creates a new color using RGB or RGBA representation.
- `FromHex(hex)`: Creates a new color using Hex RGB or RGBA representation.
- `FromHSL(h, s, l)`: Creates a Color instance from HSL format.
- `FromHWB(h, w, b)`: Creates a Color instance from HWB format.
- `FromCMYK(c, m, y, k)`: Creates a Color instance from CMYK format.
- `FromNCol(h, w, b)`: Creates a Color instance from NCol format.
- `FromXYZ(x, y, z)`: Creates a Color instance from XYZ format.
- `FromLab(l, a, b)`: Creates a Color instance from Lab format.
- `FromYIQ(y, i, q)`: Creates a Color instance from YIQ format.
- `Average(colors*)`: Calculates the average of two or more colors.
- `Multiply(colors*)`: Multiplies two or more colors.
