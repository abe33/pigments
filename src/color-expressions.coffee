
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

# #3489ef
Color.addExpression 'css_hexa_6', "#(#{hexa}{6})(?![\\d\\w])", (color, expression) ->
  [_, hexa] = @onigRegExp.exec(expression)

  color.hex = hexa

# #38e
Color.addExpression 'css_hexa_3', "#(#{hexa}{3})(?![\\d\\w])", (color, expression) ->
  [_, hexa] = @onigRegExp.exec(expression)
  colorAsInt = parseInt(hexa, 16)

  color.red = (colorAsInt >> 8 & 0xf) * 17
  color.green = (colorAsInt >> 4 & 0xf) * 17
  color.blue = (colorAsInt & 0xf) * 17

# 0xab3489ef
Color.addExpression 'int_hexa_8', "0x(#{hexa}{8})(?!#{hexa})", (color, expression) ->
  [_, hexa] = @onigRegExp.exec(expression)

  color.hexARGB = hexa

# 0x3489ef
Color.addExpression 'int_hexa_6', "0x(#{hexa}{6})(?!#{hexa})", (color, expression) ->
  [_, hexa] = @onigRegExp.exec(expression)

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
"), (color, expression, fileVariables) ->
  [_,r,_,_,g,_,_,b] = @onigRegExp.exec(expression)

  color.red = parseIntOrPercent(r, fileVariables)
  color.green = parseIntOrPercent(g, fileVariables)
  color.blue = parseIntOrPercent(b, fileVariables)
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
"), (color, expression, fileVariables) ->
  [_,r,_,_,g,_,_,b,_,_,a] = @onigRegExp.exec(expression)

  color.red = parseIntOrPercent(r, fileVariables)
  color.green = parseIntOrPercent(g, fileVariables)
  color.blue = parseIntOrPercent(b, fileVariables)
  color.alpha = parseFloat(a, fileVariables)

# hsl(210,50%,50%)
Color.addExpression 'css_hsl', strip("
  hsl#{ps}\\s*
    (#{int}|#{variables})
    #{comma}
    (#{percent}|#{variables})
    #{comma}
    (#{percent}|#{variables})
  #{pe}
"), (color, expression, fileVariables) ->
  [_,h,_,s,_,l] = @onigRegExp.exec(expression)

  color.hsl = [
    parseInt(h, fileVariables)
    parseFloat(s, fileVariables)
    parseFloat(l, fileVariables)
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
"), (color, expression, fileVariables) ->
  [_,h,_,s,_,l,_,a] = @onigRegExp.exec(expression)

  color.hsl = [
    parseInt(h,fileVariables)
    parseFloat(s,fileVariables)
    parseFloat(l,fileVariables)
  ]
  color.alpha = parseFloat(a,fileVariables)

# hsv(210,70%,90%)
Color.addExpression 'hsv', strip("
  hsv#{ps}\\s*
    (#{int}|#{variables})
    #{comma}
    (#{percent}|#{variables})
    #{comma}
    (#{percent}|#{variables})
  #{pe}
"), (color, expression, fileVariables) ->
  [_,h,_,s,_,v] = @onigRegExp.exec(expression)

  color.hsv = [
    parseInt(h, fileVariables)
    parseFloat(s, fileVariables)
    parseFloat(v, fileVariables)
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
"), (color, expression, fileVariables) ->
  [_,h,_,s,_,v,_,a] = @onigRegExp.exec(expression)

  color.hsv = [
    parseInt(h, fileVariables)
    parseFloat(s, fileVariables)
    parseFloat(v, fileVariables)
  ]
  color.alpha = parseFloat(a, fileVariables)


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
  [_,h,s,l,a] = @onigRegExp.exec(expression)

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
"), (color, expression, fileVariables) ->
  [_,h,_,w,_,b,_,_,a] = @onigRegExp.exec(expression)

  color.hwb = [
    parseInt(h, fileVariables)
    parseFloat(w, fileVariables)
    parseFloat(b, fileVariables)
  ]
  color.alpha = if a? then parseFloat(a, fileVariables) else 1

# gray(50%)
# The priority is set to 1 to make sure that it appears before named colors
Color.addExpression 'gray', strip("
  gray#{ps}\\s*
    (#{percent})
    (#{comma}(#{float}))?
  #{pe}"), 1, (color, expression) ->
  [_,p,_,a] = @onigRegExp.exec(expression)

  p = parseFloat(p) / 100 * 255
  color.rgb = [p, p, p]
  color.alpha = if a? then parseFloat(a) else 1

# dodgerblue
colors = Object.keys(Color.namedColors)

colorRegexp = "(#{namePrefixes})(#{colors.join('|')})(?!\\s*[-\\.:=])\\b"

Color.addExpression 'named_colors', colorRegexp, (color, expression) ->
  [_,_,name] = @onigRegExp.exec(expression)

  color.colorExpression = color.name = name
