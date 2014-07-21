Color = require './color-model'
cssColor = require 'css-color-function'

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
  variables
} = require './regexes'

{
  strip
  split
  clamp
  clampInt
  parseInt
  parseFloat
  parseIntOrPercent
  parseFloatOrPercent
} = require './utils'

MAX_PER_COMPONENT =
  red: 255
  green: 255
  blue: 255
  alpha: 1
  hue: 360
  saturation: 100
  lightness: 100

# darken(#666666, 20%)
Color.addExpression 'darken', "darken#{ps}(#{notQuote})#{comma}(#{percent}|#{variables})#{pe}", (color, expression, fileVariables) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match
  amount = parseFloat(amount.match, fileVariables)

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr, fileVariables)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, s, clampInt(l - l * (amount / 100))]
    color.alpha = baseColor.alpha
  else
    color.isInvalid = true

# lighten(#666666, 20%)
Color.addExpression 'lighten', "lighten#{ps}(#{notQuote})#{comma}(#{percent}|#{variables})#{pe}", (color, expression, fileVariables) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match
  amount = parseFloat(amount.match, fileVariables)

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, s, clampInt(l + l * (amount / 100))]
    color.alpha = baseColor.alpha
  else
    color.isInvalid = true

# transparentize(#ffffff, 0.5)
# transparentize(#ffffff, 50%)
# fadein(#ffffff, 0.5)
Color.addExpression 'transparentize', "(transparentize|fadein)#{ps}(#{notQuote})#{comma}(#{floatOrPercent}|#{variables})#{pe}", (color, expression, fileVariables) ->
  [_, _, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match
  amount = parseFloatOrPercent amount.match, fileVariables

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    color.rgb = baseColor.rgb
    color.alpha = clamp(baseColor.alpha - amount)
  else
    color.isInvalid = true

# opacify(0x78ffffff, 0.5)
# opacify(0x78ffffff, 50%)
# fadeout(0x78ffffff, 0.5)
Color.addExpression 'opacify', "(opacify|fadeout)#{ps}(#{notQuote})#{comma}(#{floatOrPercent}|#{variables})#{pe}", (color, expression, fileVariables) ->
  [_, _, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match

  amount = parseFloatOrPercent amount.match, fileVariables

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    color.rgb = baseColor.rgb
    color.alpha = clamp(baseColor.alpha + amount)
  else
    color.isInvalid = true

# adjust-hue(#855, 60deg)
Color.addExpression 'adjust-hue', "adjust-hue#{ps}(#{notQuote})#{comma}(-?#{int}deg|#{variables})#{pe}", (color, expression, fileVariables) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match

  amount = parseFloatOrPercent amount.match, fileVariables

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [(h + amount) % 360, s, l]
    color.alpha = baseColor.alpha
  else
    color.isInvalid = true

# mix(#f00, #00F, 25%)
# mix(#f00, #00F)
Color.addExpression 'mix', "mix#{ps}((#{notQuote})#{comma} (#{notQuote})#{comma}(#{floatOrPercent}|#{variables})|(#{notQuote})#{comma}(#{notQuote}))#{pe}", (color, expression, fileVariables) ->
  [_, _, color1A, color2A, amount, _, _, color1B, color2B] = @onigRegExp.searchSync(expression)

  if color1A.match.length > 0
    color1 = color1A.match
    color2 = color2A.match
    amount = parseFloatOrPercent amount?.match, fileVariables
  else
    color1 = color1B.match
    color2 = color2B.match
    amount = 0.5

  if Color.canHandle(color1) and Color.canHandle(color2) and not isNaN(amount)
    baseColor1 = new Color(color1)
    baseColor2 = new Color(color2)

    color.rgba = Color.mixColors(baseColor1, baseColor2, amount).rgba
  else
    color.isInvalid = true

# tint(red, 50%)
Color.addExpression 'tint', "tint#{ps}(#{notQuote})#{comma}(#{floatOrPercent}|#{variables})#{pe}", (color, expression, fileVariables) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match
  amount = parseFloatOrPercent(amount.match, fileVariables)

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    white = new Color('white')

    color.rgba = Color.mixColors(white, baseColor, amount).rgba
  else
    color.isInvalid = true

# shade(red, 50%)
Color.addExpression 'shade', "shade#{ps}(#{notQuote})#{comma}(#{floatOrPercent}|#{variables})#{pe}", (color, expression, fileVariables) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match
  amount = parseFloatOrPercent(amount.match, fileVariables)

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    black = new Color('black')

    color.rgba = Color.mixColors(black, baseColor, amount).rgba
  else
    color.isInvalid = true

# desaturate(#855, 20%)
# desaturate(#855, 0.2)
Color.addExpression 'desaturate', "desaturate#{ps}(#{notQuote})#{comma}(#{floatOrPercent}|#{variables})#{pe}", (color, expression, fileVariables) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match

  amount = parseFloatOrPercent amount.match, fileVariables

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, clampInt(s - amount * 100), l]
    color.alpha = baseColor.alpha
  else
    color.isInvalid = true

# saturate(#855, 20%)
# saturate(#855, 0.2)
Color.addExpression 'saturate', "saturate#{ps}(#{notQuote})#{comma}(#{floatOrPercent}|#{variables})#{pe}", (color, expression, fileVariables) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match

  amount = parseFloatOrPercent amount.match, fileVariables

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr, fileVariables)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, clampInt(s + amount * 100), l]
    color.alpha = baseColor.alpha
  else
    color.isInvalid = true

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

# color(green tint(50%))
Color.addExpression 'css_color_function', "color#{ps}(#{notQuote})#{pe}", (color, expression) ->
  rgba = cssColor.convert(expression)
  color.rgba = new Color(rgba).rgba

parseParam = (param, fileVariables={}, block) ->
  [block, fileVariables] = [fileVariables, {}] if typeof fileVariables is 'function'
  re = ///\$(\w+):\s*((-?#{float})|#{variables})///
  if re.test(param)
    [_, name, value] = re.exec(param)
    value = fileVariables[value]?.value if ///#{variables}///.test(value)

    block(name, value)

# adjust-color(red, $lightness: 30%)
Color.addExpression 'sass_adjust_color', "adjust-color#{ps}(#{notQuote})#{pe}", 1, (color, expression, fileVariables) ->
  [_, subexpr] = @onigRegExp.searchSync(expression)
  [subject, params...] = split(subexpr.match)

  refColor = new Color(subject, fileVariables)

  for param in params
    parseParam param, fileVariables, (name, value) ->
      refColor[name] += parseFloat(value)

  color.rgba = refColor.rgba

# scale-color(red, $lightness: 30%)
Color.addExpression 'sass_scale_color', "scale-color#{ps}(#{notQuote})#{pe}", 1, (color, expression, fileVariables) ->

  [_, subexpr] = @onigRegExp.searchSync(expression)
  [subject, params...] = split(subexpr.match)
  refColor = new Color(subject, fileVariables)

  for param in params
    parseParam param, fileVariables, (name, value) ->
      value = parseFloat(value) / 100

      result = if value > 0
        dif = MAX_PER_COMPONENT[name] - refColor[name]
        result = refColor[name] + dif * value
      else
        result = refColor[name] * (1+value)

      refColor[name] = result

  color.rgba = refColor.rgba

# change-color(red, $lightness: 30%)
Color.addExpression 'sass_change_color', "change-color#{ps}(#{notQuote})#{pe}", 1, (color, expression, fileVariables) ->
  [_, subexpr] = @onigRegExp.searchSync(expression)
  [subject, params...] = split(subexpr.match)

  refColor = new Color(subject, fileVariables)

  for param in params
    parseParam param, fileVariables, (name, value) ->
      refColor[name] = parseFloat(value)

  color.rgba = refColor.rgba
