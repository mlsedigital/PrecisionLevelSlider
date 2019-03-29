# PrecisionLevelSlider

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

UI component library, such as Apple's Photos app.

Pro

<p align="center">
  <img src="sample.png" width=375>
</p>

<p align="center">
  <img src="sample.gif" width=375>
</p>

## Attributes
The following value attributes are exposed:
  - value : Float
  - minimumValue : Float
  - maximumValue : Float
  - isContinuous : Bool
    - determines if the value updates on the fly while scrubbing through
  - notchCount : Int

The following styling attributes are exposed:
  - longNotchColor : UIColor
  - shortNotchColor : UIColor
  - centerNotchColor : UIColor
  - longNotchSize : CGSize
  - shortNotchSize : CGSize
  - centerNotchSize : CGSize
  - longNotchCornerRadius: CGFloat
  - shortNotchCornerRadius: CGFloat
  - centerNotchCornerRadius: CGFloat
  - longNotchGroup : Int
    - determines how many notches in between would the long notch show up
  - notchSpacing : Float
    - how far apart the notches are
  - notchFont : UIFont?
    - if present, adds a label denoting the value of the long notch
  - applyMask : Bool (default: true)
    - applies the gradient on left and right sides
