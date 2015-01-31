
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
  parseInt
  parseFloat
  parseIntOrPercent
  parseFloatOrPercent
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
  colorAsInt = parseInt(hexa, 16)

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

  color.red = parseIntOrPercent(r, vars)
  color.green = parseIntOrPercent(g, vars)
  color.blue = parseIntOrPercent(b, vars)
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

  color.red = parseIntOrPercent(r, vars)
  color.green = parseIntOrPercent(g, vars)
  color.blue = parseIntOrPercent(b, vars)
  color.alpha = parseFloat(a, vars)

# rgba(green,0.7)
Color.addExpression 'stylus_rgba', strip("
  rgba#{ps}\\s*
    (#{notQuote})
    #{comma}
    (#{float}|#{variables})
  #{pe}
"), (color, expression, vars) ->
  [_,subexpr,a] = @regExp.exec(expression)

  subexpr = vars[subexpr]?.value ? subexpr
  baseColor = new Color(subexpr, vars)
  color.rgb = baseColor.rgb
  color.alpha = parseFloat(a, vars)

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
    parseInt(h, vars)
    parseFloat(s, vars)
    parseFloat(l, vars)
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
    parseInt(h,vars)
    parseFloat(s,vars)
    parseFloat(l,vars)
  ]
  color.alpha = parseFloat(a,vars)

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
    parseInt(h, vars)
    parseFloat(s, vars)
    parseFloat(v, vars)
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
    parseInt(h, vars)
    parseFloat(s, vars)
    parseFloat(v, vars)
  ]
  color.alpha = parseFloat(a, vars)


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
    parseFloat(h) * 255
    parseFloat(s) * 255
    parseFloat(l) * 255
    parseFloat(a)
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
    parseInt(h, vars)
    parseFloat(w, vars)
    parseFloat(b, vars)
  ]
  color.alpha = if a? then parseFloat(a, vars) else 1

# gray(50%)
# The priority is set to 1 to make sure that it appears before named colors
Color.addExpression 'gray', strip("
  gray#{ps}\\s*
    (#{percent}|#{variables})
    (#{comma}(#{float}|#{variables}))?
  #{pe}"), 1, (color, expression, vars) ->

  [_,p,_,_,a] = @regExp.exec(expression)

  p = parseFloat(p, vars) / 100 * 255
  color.rgb = [p, p, p]
  color.alpha = if a? then parseFloat(a, vars) else 1

# dodgerblue
colors = Object.keys(Color.namedColors)

colorRegexp = "(#{namePrefixes})(#{colors.join('|')})(?!\\s*[-\\.:=\\(])\\b"

Color.addExpression 'named_colors', colorRegexp, (color, expression) ->
  [_,_,name] = @regExp.exec(expression)

  color.colorExpression = color.name = name
