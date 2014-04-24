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
  parseIntOrPercent
  parseFloatOrPercent
} = require './utils'

# darken(#666666, 20%)
Color.addExpression 'darken', "darken#{ps}(#{notQuote})#{comma}(#{percent})#{pe}", (color, expression) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match
  amount = parseFloat(amount.match)

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, s, clampInt(l - l * (amount / 100))]
    color.alpha = baseColor.alpha

# lighten(#666666, 20%)
Color.addExpression 'lighten', "lighten#{ps}(#{notQuote})#{comma}(#{percent})#{pe}", (color, expression) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match
  amount = parseFloat(amount.match)

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, s, clampInt(l + l * (amount / 100))]
    color.alpha = baseColor.alpha

# transparentize(#ffffff, 0.5)
# transparentize(#ffffff, 50%)
# fadein(#ffffff, 0.5)
Color.addExpression 'transparentize', "(transparentize|fadein)#{ps}(#{notQuote})#{comma}(#{floatOrPercent})#{pe}", (color, expression) ->
  [_, _, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match
  amount = parseFloatOrPercent amount.match

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    color.rgb = baseColor.rgb
    color.alpha = clamp(baseColor.alpha - amount)

# opacify(0x78ffffff, 0.5)
# opacify(0x78ffffff, 50%)
# fadeout(0x78ffffff, 0.5)
Color.addExpression 'opacify', "(opacify|fadeout)#{ps}(#{notQuote})#{comma}(#{floatOrPercent})#{pe}", (color, expression) ->
  [_, _, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match

  amount = parseFloatOrPercent amount.match

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    color.rgb = baseColor.rgb
    color.alpha = clamp(baseColor.alpha + amount)

# adjust-hue(#855, 60deg)
Color.addExpression 'adjust-hue', "adjust-hue#{ps}(#{notQuote})#{comma}(-?#{int})deg#{pe}", (color, expression) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match

  amount = parseFloatOrPercent amount.match

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [(h + amount) % 360, s, l]
    color.alpha = baseColor.alpha

# mix(#f00, #00F, 25%)
# mix(#f00, #00F)
Color.addExpression 'mix', "mix#{ps}((#{notQuote})#{comma} (#{notQuote})#{comma}(#{floatOrPercent})|(#{notQuote})#{comma}(#{notQuote}))#{pe}", (color, expression) ->
  [_, _, color1A, color2A, amount, _, color1B, color2B] = @onigRegExp.searchSync(expression)

  if color1A.match.length > 0
    color1 = color1A.match
    color2 = color2A.match
    amount = parseFloatOrPercent amount?.match
  else
    color1 = color1B.match
    color2 = color2B.match
    amount = 0.5

  if Color.canHandle(color1) and Color.canHandle(color2) and not isNaN(amount)
    baseColor1 = new Color(color1)
    baseColor2 = new Color(color2)

    color.rgba = Color.mixColors(baseColor1, baseColor2, amount).rgba

# tint(red, 50%)
Color.addExpression 'tint', "tint#{ps}(#{notQuote})#{comma}(#{floatOrPercent})#{pe}", (color, expression) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match
  amount = parseFloatOrPercent(amount.match)

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    white = new Color('white')

    color.rgba = Color.mixColors(white, baseColor, amount).rgba

# shade(red, 50%)
Color.addExpression 'shade', "shade#{ps}(#{notQuote})#{comma}(#{floatOrPercent})#{pe}", (color, expression) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match
  amount = parseFloatOrPercent(amount.match)

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    black = new Color('black')

    color.rgba = Color.mixColors(black, baseColor, amount).rgba


# desaturate(#855, 20%)
# desaturate(#855, 0.2)
Color.addExpression 'desaturate', "desaturate#{ps}(#{notQuote})#{comma}(#{floatOrPercent})#{pe}", (color, expression) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match

  amount = parseFloatOrPercent amount.match

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, clampInt(s - amount * 100), l]
    color.alpha = baseColor.alpha

# saturate(#855, 20%)
# saturate(#855, 0.2)
Color.addExpression 'saturate', "saturate#{ps}(#{notQuote})#{comma}(#{floatOrPercent})#{pe}", (color, expression) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match

  amount = parseFloatOrPercent amount.match

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, clampInt(s + amount * 100), l]
    color.alpha = baseColor.alpha

# grayscale(red)
# greyscale(red)
Color.addExpression 'grayscale', "gr(a|e)yscale#{ps}(#{notQuote})#{pe}", (color, expression) ->
  [_, _, subexpr] = @onigRegExp.searchSync(expression)
  subexpr = subexpr.match

  if Color.canHandle(subexpr)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, 0, l]
    color.alpha = baseColor.alpha

# invert(green)
Color.addExpression 'input', "invert#{ps}(#{notQuote})#{pe}", (color, expression) ->
  [_, subexpr] = @onigRegExp.searchSync(expression)
  subexpr = subexpr.match

  if Color.canHandle(subexpr)
    baseColor = new Color(subexpr)
    [r,g,b] = baseColor.rgb

    color.rgb = [255 - r, 255 - g, 255 - b]
    color.alpha = baseColor.alpha
