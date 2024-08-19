# YACS - Yet Another Color Selector

## Introduction

YACS is a project that started out as just a small function of a few lines, to just grab the color under the cursor and copy it to the clipboard. Then I decided that I wanted to see the color i was hovering over. Then I decided I wanted to see more than one pixel in the color preview. It was at that point that I realized I would need to use GDI to make this usable. Now, it's a fully featured color selector that you can use standalone, or in your own projects!

## Table of Contents

 1. [Introduction](#introduction)

 2. [Properties](#properties)

 3. [Methods](#methods)

 4. [Usage](#usage)

## Properties

 1. **`FontName`**

     - The name of the font to use for the label on the `ColorPicker` preview window.

 2. **`FontSize`**

     - The size of the font to use for the label on the `ColorPicker` preview window.

 3. **`ViewMode`**

     - Can be "crosshair", "grid", any other value will result in the "blank" overlay with the center dot highlighter.

 4. **`UpdateInterval`**

     - The interval at which the preview will update, in milliseconds. 16ms = ~60 updates / second.

 5. **`HighlightCenter`**

     - If True, highlights the pixel that the color is copied from.

 6. **`BorderWidth`**

     - Thickness of the preview border, in pixels.

 7. **`CrosshairWidth`**

     - Thickness of crosshair lines, in pixels.

 8. **`GridWidth`**

     - Thickness of grid lines, in pixels.

 9. **`CenterDotRadius`**

     - Radius of the Center Dot when not in "grid" or "crosshair" mode, in pixels.

 10. **`TextPadding`**

     - The padding added above and below the preview Hex String, in pixels (half above, half below)

 11. **`DefaultCaptureSize`**

     - The size of area you want to capture around the cursor in pixels (N by N square).

 12. **`DefaultZoomFactor`**

     - The amount by which to multiply the preview size.

     - `window side length in pixels = captureSize * zoomFactor.` EX: (9 * 11 = 99x99 pixel preview)

 13. **`LargeJumpAmount`**

     - How many pixels to move the preview window by when holding shift and moving it with the keyboard.

 14. Color Arrays:

     - Each array holds two values. The first value in each array is for one theme, and the second value is for the other

     1. **`TextFGColors[]`**, **`TextBGColors[]`**

         - Text Foreground and Background color control

         - Holds two hexadecimal values in the format `0xBBGGRR`. Switch between colors while running by pressing `C`.

     2. **`BorderColors[]`**, **`CrosshairColors[]`**, **`GridColors[]`**, **`HighlightColors[]`**

         - Border, Crosshair, Grid, and Highlighter color control.

         - Holds two hexadecimal values in the format `0xAABBGGRR`. Switch between colors while running by pressing `C`.

15. Format Strings

    - The format strings control the format of the output object.

    1. **`HexFormat`**

        - Default: `"#{R}{G}{B}"`

        - `{R}`: Represents the `R` channel.

        - `{G}`: Represents the `G` channel.

        - `{B}`: Represents the `B` channel.

    2. **`RGBFormat`**

        - Default: `"rgb({R}, {G}, {B})"`

        - `{R}`: Represents the `R` channel.

        - `{G}`: Represents the `G` channel.

        - `{B}`: Represents the `B` channel.

16. **`Color`**

    - The output `Color`, please refer to the `Color` class definition for more details.

17. **`Clip`**

    - If `True`, copies the selected color value to the clipboard.

18. **`TargetHWND`**

    - If assigned a valid HWND, the ColorPicker will be locked inside of that window or control.

19. **`Callback`**

    - Can be assigned any function that takes a single argument.

    - The object passed to the callback function is the same as the output object.

    - The callback is called on ***every*** update of the ColorPicker. Depending on what your callback does, it can slow the operation down considerably.

## Methods

1. Constructor: **`ColorPicker(clip := False, hwnd := 0, callback := 0)`**

    - Creates a new instance of `ColorPicker`

    - Arguments:

        1. **`clip`**: If true, the chosen color will be copied to the clipboard

        2. **`hwnd`**: When provided with a valid HWND, the ColorPicker will be locked inside of that window or control.

        3. **`callback`**: Provide a function that takes one argument. The object provided to the function is the same as `ColorPicker.Color`. This will be called on ***every*** update of the ColorPicker.

2. **`Start(clip := False, hwnd := 0, callback := 0)`**

    - Starts the `ColorPicker` instance with the provided options and property values.

    - Arguments:

        1. **`clip`**: If true, the chosen color will be copied to the clipboard

        2. **`hwnd`**: When provided with a valid HWND, the ColorPicker will be locked inside of that window or control.

        3. **`callback`**: Provide a function that takes one argument. The object provided to the function is the same as `ColorPicker.Color`. This will be called on ***every*** update of the ColorPicker.

3. **`static Run(clip := False, hwnd := 0, callback := 0)`**

    - Starts a `ColorPicker` with default values.

    - Does ***not*** create a persistent `ColorPicker` instance.

    - Arguments:

        1. **`clip`**: If true, the chosen color will be copied to the clipboard

        2. **`hwnd`**: When provided with a valid HWND, the ColorPicker will be locked inside of that window or control.

        3. **`callback`**: Provide a function that takes one argument. The object provided to the function is the same as `ColorPicker.Color`. This will be called on ***every*** update of the ColorPicker.

## Usage

1. To use, just create an instance of `ColorPicker`. If you don't pass arguments now, you can assign those properties later:

    - `picker := ColorPicker()`

2. Change any properties you want to change:

    - `picker.FontName := "Papyrus"`

    - `picker.FontSize := 16`

    - `picker.TargetHWND := ControlGetHwnd(control)`

3. Start the `ColorPicker`!

    - `color := picker.Start()`

### OR

1. If you don't want to create an instance of `ColorPicker`, you can use a static method :

    - `color := ColorPicker.Run()`
