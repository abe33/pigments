
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
  variables
  namePrefixes
} = require './regexes'

{
  strip
  clamp
  clampInt
  readInt
  readFloat
  readIntOrPercent
  readFloatOrPercent
} = require './utils'

# #6f3489ef
Color.addExpression 'css_hexa_8', "#(#{hexa}{8})(?![\\d\\w])", (color, expression) ->
  [_, hexa] = @regExp.exec(expression)

  color.hexARGB = hexa

# #3489ef
Color.addExpression 'css_hexa_6', "#(#{hexa}{6})(?![\\d\\w])", (color, expression) ->
  [_, hexa] = @regExp.exec(expression)

  color.hex = hexa

# #38e
Color.addExpression 'css_hexa_3', "#(#{hexa}{3})(?![\\d\\w])", (color, expression) ->
  [_, hexa] = @regExp.exec(expression)
  colorAsInt = readInt(hexa, {}, color, 16)

  color.red = (colorAsInt >> 8 & 0xf) * 17
  color.green = (colorAsInt >> 4 & 0xf) * 17
  color.blue = (colorAsInt & 0xf) * 17

# 0xab3489ef
Color.addExpression 'int_hexa_8', "0x(#{hexa}{8})(?!#{hexa})", (color, expression) ->
  [_, hexa] = @regExp.exec(expression)

  color.hexARGB = hexa

# 0x3489ef
Color.addExpression 'int_hexa_6', "0x(#{hexa}{6})(?!#{hexa})", (color, expression) ->
  [_, hexa] = @regExp.exec(expression)

  color.hex = hexa

# rgb(50,120,200)
Color.addExpression 'css_rgb', strip("
  rgb#{ps}\\s*
    (#{intOrPercent}|#{variables})
    #{comma}
    (#{intOrPercent}|#{variables})
    #{comma}
    (#{intOrPercent}|#{variables})
  #{pe}
"), (color, expression, vars) ->
  [_,r,_,_,g,_,_,b] = @regExp.exec(expression)

  color.red = readIntOrPercent(r, vars, color)
  color.green = readIntOrPercent(g, vars, color)
  color.blue = readIntOrPercent(b, vars, color)
  color.alpha = 1

# rgba(50,120,200,0.7)
Color.addExpression 'css_rgba', strip("
  rgba#{ps}\\s*
    (#{intOrPercent}|#{variables})
    #{comma}
    (#{intOrPercent}|#{variables})
    #{comma}
    (#{intOrPercent}|#{variables})
    #{comma}
    (#{float}|#{variables})
  #{pe}
"), (color, expression, vars) ->
  [_,r,_,_,g,_,_,b,_,_,a] = @regExp.exec(expression)

  color.red = readIntOrPercent(r, vars, color)
  color.green = readIntOrPercent(g, vars, color)
  color.blue = readIntOrPercent(b, vars, color)
  color.alpha = readFloat(a, vars, color)

# rgba(green,0.7)
Color.addExpression 'stylus_rgba', strip("
  rgba#{ps}\\s*
    (#{notQuote})
    #{comma}
    (#{float}|#{variables})
  #{pe}
"), (color, expression, vars) ->
  [_,subexpr,a] = @regExp.exec(expression)

  if vars[subexpr]?
    color.usedVariables.push(subexpr)
    subexpr = vars[subexpr].value

  if Color.canHandle(subexpr)
    baseColor = new Color(subexpr, vars)
    color.rgb = baseColor.rgb
    color.alpha = readFloat(a, vars, color)
  else
    color.isInvalid = true

# hsl(210,50%,50%)
Color.addExpression 'css_hsl', strip("
  hsl#{ps}\\s*
    (#{int}|#{variables})
    #{comma}
    (#{percent}|#{variables})
    #{comma}
    (#{percent}|#{variables})
  #{pe}
"), (color, expression, vars) ->
  [_,h,_,s,_,l] = @regExp.exec(expression)

  color.hsl = [
    readInt(h, vars, color)
    readFloat(s, vars, color)
    readFloat(l, vars, color)
  ]
  color.alpha = 1

# hsla(210,50%,50%,0.7)
Color.addExpression 'css_hsla', strip("
  hsla#{ps}\\s*
    (#{int}|#{variables})
    #{comma}
    (#{percent}|#{variables})
    #{comma}
    (#{percent}|#{variables})
    #{comma}
    (#{float}|#{variables})
  #{pe}
"), (color, expression, vars) ->
  [_,h,_,s,_,l,_,a] = @regExp.exec(expression)

  color.hsl = [
    readInt(h, vars, color)
    readFloat(s,vars, color)
    readFloat(l,vars, color)
  ]
  color.alpha = readFloat(a,vars, color)

# hsv(210,70%,90%)
Color.addExpression 'hsv', strip("
  hsv#{ps}\\s*
    (#{int}|#{variables})
    #{comma}
    (#{percent}|#{variables})
    #{comma}
    (#{percent}|#{variables})
  #{pe}
"), (color, expression, vars) ->
  [_,h,_,s,_,v] = @regExp.exec(expression)

  color.hsv = [
    readInt(h, vars, color)
    readFloat(s, vars, color)
    readFloat(v, vars, color)
  ]
  color.alpha = 1

# hsva(210,70%,90%,0.7)
Color.addExpression 'hsva', strip("
  hsva#{ps}\\s*
    (#{int}|#{variables})
    #{comma}
    (#{percent}|#{variables})
    #{comma}
    (#{percent}|#{variables})
    #{comma}
    (#{float}|#{variables})
  #{pe}
"), (color, expression, vars) ->
  [_,h,_,s,_,v,_,a] = @regExp.exec(expression)

  color.hsv = [
    readInt(h, vars, color)
    readFloat(s, vars, color)
    readFloat(v, vars, color)
  ]
  color.alpha = readFloat(a, vars, color)


# vec4(0.2, 0.5, 0.9, 0.7)
Color.addExpression 'vec4', strip("
  vec4#{ps}\\s*
    (#{float})
    #{comma}
    (#{float})
    #{comma}
    (#{float})
    #{comma}
    (#{float})
  #{pe}
"), (color, expression) ->
  [_,h,s,l,a] = @regExp.exec(expression)

  color.rgba = [
    readFloat(h, vars, color) * 255
    readFloat(s, vars, color) * 255
    readFloat(l, vars, color) * 255
    readFloat(a, vars, color)
  ]

# hwb(210,40%,40%)
Color.addExpression 'hwb', strip("
  hwb#{ps}\\s*
    (#{int}|#{variables})
    #{comma}
    (#{percent}|#{variables})
    #{comma}
    (#{percent}|#{variables})
    (#{comma}(#{float}|#{variables}))?
  #{pe}
"), (color, expression, vars) ->
  [_,h,_,w,_,b,_,_,a] = @regExp.exec(expression)

  color.hwb = [
    readInt(h, vars, color)
    readFloat(w, vars, color)
    readFloat(b, vars, color)
  ]
  color.alpha = if a? then readFloat(a, vars, color) else 1

# gray(50%)
# The priority is set to 1 to make sure that it appears before named colors
Color.addExpression 'gray', strip("
  gray#{ps}\\s*
    (#{percent}|#{variables})
    (#{comma}(#{float}|#{variables}))?
  #{pe}"), 1, (color, expression, vars) ->

  [_,p,_,_,a] = @regExp.exec(expression)

  p = readFloat(p, vars, color) / 100 * 255
  color.rgb = [p, p, p]
  color.alpha = if a? then readFloat(a, vars, color) else 1

# dodgerblue
colors = Object.keys(Color.namedColors)

colorRegexp = "(#{namePrefixes})(#{colors.join('|')})(?!\\s*[-\\.:=\\(])\\b"

Color.addExpression 'named_colors', colorRegexp, (color, expression) ->
  [_,_,name] = @regExp.exec(expression)

  color.colorExpression = color.name = name
