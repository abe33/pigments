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
  readInt
  readFloat
  readIntOrPercent
  readFloatOrPercent
  readDegreesOrPercent
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
Color.addExpression 'darken', "darken#{ps}(#{notQuote})#{comma}(#{percent}|#{variables})#{pe}", (color, expression, vars) ->
  [_, subexpr, amount] = @regExp.exec(expression)

  amount = readFloat(amount, vars, color)

  if vars[subexpr]?
    color.usedVariables.push(subexpr)
    subexpr = vars[subexpr].value

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr, vars)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, s, clampInt(l - amount)]
    color.alpha = baseColor.alpha
    color.usedVariables = color.usedVariables.concat(baseColor.usedVariables)
  else
    color.isInvalid = true

# lighten(#666666, 20%)
Color.addExpression 'lighten', "lighten#{ps}(#{notQuote})#{comma}(#{percent}|#{variables})#{pe}", (color, expression, vars) ->
  [_, subexpr, amount] = @regExp.exec(expression)

  amount = readFloat(amount, vars, color)

  if vars[subexpr]?
    color.usedVariables.push(subexpr)
    subexpr = vars[subexpr].value

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr, vars)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, s, clampInt(l + amount)]
    color.alpha = baseColor.alpha
    color.usedVariables = color.usedVariables.concat(baseColor.usedVariables)
  else
    color.isInvalid = true

# transparentize(#ffffff, 0.5)
# transparentize(#ffffff, 50%)
# fadein(#ffffff, 0.5)
Color.addExpression 'transparentize', "(transparentize|fadein)#{ps}(#{notQuote})#{comma}(#{floatOrPercent}|#{variables})#{pe}", (color, expression, vars) ->
  [_, _, subexpr, amount] = @regExp.exec(expression)

  amount = readFloatOrPercent(amount, vars, color)

  if vars[subexpr]?
    color.usedVariables.push(subexpr)
    subexpr = vars[subexpr].value

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr, vars)
    color.rgb = baseColor.rgb
    color.alpha = clamp(baseColor.alpha - amount)
    color.usedVariables = color.usedVariables.concat(baseColor.usedVariables)
  else
    color.isInvalid = true

# opacify(0x78ffffff, 0.5)
# opacify(0x78ffffff, 50%)
# fadeout(0x78ffffff, 0.5)
Color.addExpression 'opacify', "(opacify|fadeout)#{ps}(#{notQuote})#{comma}(#{floatOrPercent}|#{variables})#{pe}", (color, expression, vars) ->
  [_, _, subexpr, amount] = @regExp.exec(expression)

  amount = readFloatOrPercent(amount, vars, color)

  if vars[subexpr]?
    color.usedVariables.push(subexpr)
    subexpr = vars[subexpr].value

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr, vars)
    color.rgb = baseColor.rgb
    color.alpha = clamp(baseColor.alpha + amount)
    color.usedVariables = color.usedVariables.concat(baseColor.usedVariables)
  else
    color.isInvalid = true

# adjust-hue(#855, 60deg)
Color.addExpression 'adjust-hue', "adjust-hue#{ps}(#{notQuote})#{comma}(-?#{int}deg|#{variables}|-?#{percent})#{pe}", (color, expression, vars) ->
  [_, subexpr, amount] = @regExp.exec(expression)

  amount = readFloat(amount, vars, color)

  if vars[subexpr]?
    color.usedVariables.push(subexpr)
    subexpr = vars[subexpr].value

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr, vars)
    [h,s,l] = baseColor.hsl

    color.hsl = [(h + amount) % 360, s, l]
    color.alpha = baseColor.alpha
    color.usedVariables = color.usedVariables.concat(baseColor.usedVariables)
  else
    color.isInvalid = true

# mix(#f00, #00F, 25%)
# mix(#f00, #00F)
Color.addExpression 'mix', "mix#{ps}((#{notQuote})#{comma} (#{notQuote})#{comma}(#{floatOrPercent}|#{variables})|(#{notQuote})#{comma}(#{notQuote}))#{pe}", (color, expression, vars) ->
  [_, _, color1A, color2A, amount, _, _, color1B, color2B] = @regExp.exec(expression)

  if color1A?
    color1 = color1A
    color2 = color2A
    amount = readFloatOrPercent(amount, vars, color)
  else
    color1 = color1B
    color2 = color2B
    amount = 0.5

  if vars[color1]?
    color.usedVariables.push(color1)
    color1 = vars[color1].value

  if vars[color2]?
    color.usedVariables.push(color2)
    color2 = vars[color2].value

  if Color.canHandle(color1) and Color.canHandle(color2) and not isNaN(amount)
    baseColor1 = new Color(color1, vars)
    baseColor2 = new Color(color2, vars)

    color.rgba = Color.mixColors(baseColor1, baseColor2, amount).rgba

    color.usedVariables = color.usedVariables.concat(baseColor1.usedVariables)
    color.usedVariables = color.usedVariables.concat(baseColor2.usedVariables)
  else
    color.isInvalid = true

# tint(red, 50%)
Color.addExpression 'tint', "tint#{ps}(#{notQuote})#{comma}(#{floatOrPercent}|#{variables})#{pe}", (color, expression, vars) ->
  [_, subexpr, amount] = @regExp.exec(expression)

  amount = readFloatOrPercent(amount, vars, color)

  if vars[subexpr]?
    color.usedVariables.push(subexpr)
    subexpr = vars[subexpr].value

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr, vars)
    white = new Color('white')

    color.rgba = Color.mixColors(white, baseColor, amount).rgba
    color.usedVariables = color.usedVariables.concat(baseColor.usedVariables)
  else
    color.isInvalid = true

# shade(red, 50%)
Color.addExpression 'shade', "shade#{ps}(#{notQuote})#{comma}(#{floatOrPercent}|#{variables})#{pe}", (color, expression, vars) ->
  [_, subexpr, amount] = @regExp.exec(expression)

  amount = readFloatOrPercent(amount, vars, color)

  if vars[subexpr]?
    color.usedVariables.push(subexpr)
    subexpr = vars[subexpr].value

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr, vars)
    black = new Color('black')

    color.rgba = Color.mixColors(black, baseColor, amount).rgba
    color.usedVariables = color.usedVariables.concat(baseColor.usedVariables)
  else
    color.isInvalid = true

# desaturate(#855, 20%)
# desaturate(#855, 0.2)
Color.addExpression 'desaturate', "desaturate#{ps}(#{notQuote})#{comma}(#{floatOrPercent}|#{variables})#{pe}", (color, expression, vars) ->
  [_, subexpr, amount] = @regExp.exec(expression)

  amount = readFloatOrPercent(amount, vars, color)

  if vars[subexpr]?
    color.usedVariables.push(subexpr)
    subexpr = vars[subexpr].value

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr, vars)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, clampInt(s - amount * 100), l]
    color.alpha = baseColor.alpha
    color.usedVariables = color.usedVariables.concat(baseColor.usedVariables)
  else
    color.isInvalid = true

# saturate(#855, 20%)
# saturate(#855, 0.2)
Color.addExpression 'saturate', "saturate#{ps}(#{notQuote})#{comma}(#{floatOrPercent}|#{variables})#{pe}", (color, expression, vars) ->
  [_, subexpr, amount] = @regExp.exec(expression)

  amount = readFloatOrPercent(amount, vars, color)

  if vars[subexpr]?
    color.usedVariables.push(subexpr)
    subexpr = vars[subexpr].value

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr, vars)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, clampInt(s + amount * 100), l]
    color.alpha = baseColor.alpha
    color.usedVariables = color.usedVariables.concat(baseColor.usedVariables)
  else
    color.isInvalid = true

# grayscale(red)
# greyscale(red)
Color.addExpression 'grayscale', "gr(a|e)yscale#{ps}(#{notQuote})#{pe}", (color, expression, vars) ->
  [_, _, subexpr] = @regExp.exec(expression)

  if vars[subexpr]?
    color.usedVariables.push(subexpr)
    subexpr = vars[subexpr].value

  if Color.canHandle(subexpr)
    baseColor = new Color(subexpr, vars)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, 0, l]
    color.alpha = baseColor.alpha
    color.usedVariables = color.usedVariables.concat(baseColor.usedVariables)
  else
    color.isInvalid = true

# invert(green)
Color.addExpression 'input', "invert#{ps}(#{notQuote})#{pe}", (color, expression, vars) ->
  [_, subexpr] = @regExp.exec(expression)

  if vars[subexpr]?
    color.usedVariables.push(subexpr)
    subexpr = vars[subexpr].value

  if Color.canHandle(subexpr)
    baseColor = new Color(subexpr, vars)
    [r,g,b] = baseColor.rgb

    color.rgb = [255 - r, 255 - g, 255 - b]
    color.alpha = baseColor.alpha
    color.usedVariables = color.usedVariables.concat(baseColor.usedVariables)
  else
    color.isInvalid = true

# color(green tint(50%))
Color.addExpression 'css_color_function', "color#{ps}(#{notQuote})#{pe}", (color, expression) ->
  try
    rgba = cssColor.convert(expression)
    color.rgba = new Color(rgba).rgba
  catch e
    color.isInvalid = true

readParam = (param, vars={}, block) ->
  [block, vars] = [vars, {}] if typeof vars is 'function'
  re = ///\$(\w+):\s*((-?#{float})|#{variables})///
  if re.test(param)
    [_, name, value] = re.exec(param)

    block(name, value)

# adjust-color(red, $lightness: 30%)
Color.addExpression 'sass_adjust_color', "adjust-color#{ps}(#{notQuote})#{pe}", 1, (color, expression, vars) ->
  [_, subexpr] = @regExp.exec(expression)
  [subject, params...] = split(subexpr)

  if vars[subject]?
    color.usedVariables.push(subject)
    subject = vars[subject].value

  if Color.canHandle(subject)
    refColor = new Color(subject, vars)

    for param in params
      readParam param, vars, (name, value) ->
        refColor[name] += readFloat(value, vars, color)

    color.rgba = refColor.rgba
    color.usedVariables = color.usedVariables.concat(refColor.usedVariables)
  else
    color.isInvalid = true

# scale-color(red, $lightness: 30%)
Color.addExpression 'sass_scale_color', "scale-color#{ps}(#{notQuote})#{pe}", 1, (color, expression, vars) ->

  [_, subexpr] = @regExp.exec(expression)
  [subject, params...] = split(subexpr)

  if vars[subject]?
    color.usedVariables.push(subject)
    subject = vars[subject].value

  if Color.canHandle(subject)
    refColor = new Color(subject, vars)

    for param in params
      readParam param, vars, (name, value) ->
        value = readFloat(value, vars, color) / 100

        result = if value > 0
          dif = MAX_PER_COMPONENT[name] - refColor[name]
          result = refColor[name] + dif * value
        else
          result = refColor[name] * (1+value)

        refColor[name] = result

    color.rgba = refColor.rgba
    color.usedVariables = color.usedVariables.concat(refColor.usedVariables)
  else
    color.isInvalid = true

# change-color(red, $lightness: 30%)
Color.addExpression 'sass_change_color', "change-color#{ps}(#{notQuote})#{pe}", 1, (color, expression, vars) ->
  [_, subexpr] = @regExp.exec(expression)
  [subject, params...] = split(subexpr)

  if vars[subject]?
    color.usedVariables.push(subject)
    subject = vars[subject].value

  if Color.canHandle(subject)
    refColor = new Color(subject, vars)

    for param in params
      readParam param, vars, (name, value) ->
        refColor[name] = readFloat(value, vars, color)

    color.rgba = refColor.rgba
    color.usedVariables = color.usedVariables.concat(refColor.usedVariables)
  else
    color.isInvalid = true
