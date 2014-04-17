
Color = require './color-model'

{
  int
  float
  percent
  intOrPercent
  floatOrPercent
  comma
  notQuote
  hexa
  ps
  pe
} = require './regexes'

{
  strip
  clamp
  clampInt
  parseFloatOrPercent
  parseIntOrPercent
} = require './utils'

# darken(#666666, 20%)
Color.addOperation "\\bdarken#{ps}", Color, percent, pe, (color, [baseColor, amount]) ->
  amount = parseFloat(amount)

  [h,s,l] = baseColor.hsl

  color.hsl = [h, s, clampInt(l - l * (amount / 100))]
  color.alpha = baseColor.alpha

# lighten(#666666, 20%)
Color.addOperation "\\blighten#{ps}", Color, percent, pe, (color, [baseColor, amount]) ->
  amount = parseFloat(amount)

  [h,s,l] = baseColor.hsl

  color.hsl = [h, s, clampInt(l + l * (amount / 100))]
  color.alpha = baseColor.alpha

# transparentize(#ffffff, 0.5)
# transparentize(#ffffff, 50%)
# fadein(#ffffff, 0.5)
Color.addOperation "\\b(transparentize|fadein)#{ps}", Color, floatOrPercent, pe, (color, [baseColor, amount]) ->
  amount = parseFloatOrPercent amount

  color.rgb = baseColor.rgb
  color.alpha = clamp(baseColor.alpha - amount)

# opacify(0x78ffffff, 0.5)
# opacify(0x78ffffff, 50%)
# fadeout(0x78ffffff, 0.5)
Color.addOperation "\\b(opacify|fadeout)#{ps}", Color, floatOrPercent, pe, (color, [baseColor, amount]) ->
  amount = parseFloatOrPercent amount

  color.rgb = baseColor.rgb
  color.alpha = clamp(baseColor.alpha + amount)

# adjust-hue(#855, 60deg)
Color.addOperation "\\badjust-hue#{ps}", Color, "(-?#{int})deg", pe, (color, [baseColor, amount]) ->
  amount = parseFloatOrPercent amount

  [h,s,l] = baseColor.hsl

  color.hsl = [(h + amount) % 360, s, l]
  color.alpha = baseColor.alpha

# mix(#f00, #00F, 25%)
Color.addOperation "\\bmix#{ps}", Color, Color, floatOrPercent, pe, (color, [baseColor1, baseColor2, amount]) ->
  amount = parseFloatOrPercent amount
  color.rgba = Color.mixColors(baseColor1, baseColor2, amount).rgba

# mix(#f00, #00F)
Color.addOperation "\\bmix#{ps}", Color, Color, pe, (color, [baseColor1, baseColor2]) ->
  color.rgba = Color.mixColors(baseColor1, baseColor2, 0.5).rgba


# tint(red, 50%)
Color.addOperation "\\btint#{ps}", Color, floatOrPercent, pe, (color, [baseColor, amount]) ->
  amount = parseFloatOrPercent amount

  white = new Color('white')

  color.rgba = Color.mixColors(white, baseColor, amount).rgba


# shade(red, 50%)
Color.addOperation "\\bshade#{ps}", Color, floatOrPercent, pe, (color, [baseColor, amount]) ->
  amount = parseFloatOrPercent amount

  black = new Color('black')

  color.rgba = Color.mixColors(black, baseColor, amount).rgba

# saturate(#855, 20%)
# saturate(#855, 0.2)
Color.addOperation "\\bsaturate#{ps}", Color, floatOrPercent, pe, (color, [baseColor, amount]) ->
  amount = parseFloatOrPercent amount
  [h,s,l] = baseColor.hsl

  color.hsl = [h, clampInt(s + amount * 100), l]
  color.alpha = baseColor.alpha

# desaturate(#855, 20%)
# desaturate(#855, 0.2)
Color.addOperation "\\bdesaturate#{ps}", Color, floatOrPercent, pe, (color, [baseColor, amount]) ->
  amount = parseFloatOrPercent amount
  [h,s,l] = baseColor.hsl

  color.hsl = [h, clampInt(s - amount * 100), l]
  color.alpha = baseColor.alpha

# grayscale(red)
# greyscale(red)
Color.addOperation "\\bgr(a|e)yscale#{ps}", Color, pe, (color, [baseColor]) ->
  [h,s,l] = baseColor.hsl

  color.hsl = [h, 0, l]
  color.alpha = baseColor.alpha

# invert(green)
Color.addOperation "\\binvert#{ps}", Color, pe, (color, [baseColor]) ->
  [r,g,b] = baseColor.rgb

  color.rgb = [255 - r, 255 - g, 255 - b]
  color.alpha = baseColor.alpha
