
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

# #3489ef
Color.addExpression 'css_hexa_6', "#(#{hexa}{6})(?![\\d\\w])", (color, expression) ->
  [_, hexa] = @onigRegExp.searchSync(expression)

  color.hex = hexa.match

# #38e
Color.addExpression 'css_hexa_3', "#(#{hexa}{3})(?![\\d\\w])", (color, expression) ->
  [_, hexa] = @onigRegExp.searchSync(expression)
  colorAsInt = parseInt(hexa.match, 16)

  color.red = (colorAsInt >> 8 & 0xf) * 17
  color.green = (colorAsInt >> 4 & 0xf) * 17
  color.blue = (colorAsInt & 0xf) * 17

# 0xab3489ef
Color.addExpression 'int_hexa_8', "0x(#{hexa}{8})(?!#{hexa})", (color, expression) ->
  [_, hexa] = @onigRegExp.searchSync(expression)

  color.hexARGB = hexa.match

# 0x3489ef
Color.addExpression 'int_hexa_6', "0x(#{hexa}{6})(?!#{hexa})", (color, expression) ->
  [_, hexa] = @onigRegExp.searchSync(expression)

  color.hex = hexa.match

# rgb(50,120,200)
Color.addExpression 'css_rgb', strip("
  rgb#{ps}\\s*
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
  #{pe}
"), (color, expression) ->
  [_,r,g,b] = @onigRegExp.searchSync(expression)

  color.red = parseIntOrPercent(r.match)
  color.green = parseIntOrPercent(g.match)
  color.blue = parseIntOrPercent(b.match)
  color.alpha = 1

# rgba(50,120,200,0.7)
Color.addExpression 'css_rgba', strip("
  rgba#{ps}\\s*
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
    #{comma}
    (#{float})
  #{pe}
"), (color, expression) ->
  [_,r,g,b,a] = @onigRegExp.searchSync(expression)

  color.red = parseIntOrPercent(r.match)
  color.green = parseIntOrPercent(g.match)
  color.blue = parseIntOrPercent(b.match)
  color.alpha = parseFloat(a.match)

# hsl(210,50%,50%)
Color.addExpression 'css_hsl', strip("
  hsl#{ps}\\s*
    (#{int})
    #{comma}
    (#{percent})
    #{comma}
    (#{percent})
  #{pe}
"), (color, expression) ->
  [_,h,s,l] = @onigRegExp.searchSync(expression)

  color.hsl = [
    parseInt(h.match)
    parseFloat(s.match)
    parseFloat(l.match)
  ]
  color.alpha = 1

# hsla(210,50%,50%,0.7)
Color.addExpression 'css_hsla', strip("
  hsla#{ps}\\s*
    (#{int})
    #{comma}
    (#{percent})
    #{comma}
    (#{percent})
    #{comma}
    (#{float})
  #{pe}
"), (color, expression) ->
  [_,h,s,l,a] = @onigRegExp.searchSync(expression)

  color.hsl = [
    parseInt(h.match)
    parseFloat(s.match)
    parseFloat(l.match)
  ]
  color.alpha = parseFloat(a.match)

# hsv(210,70%,90%)
Color.addExpression 'hsv', strip("
  hsv#{ps}\\s*
    (#{int})
    #{comma}
    (#{percent})
    #{comma}
    (#{percent})
  #{pe}
"), (color, expression) ->
  [_,h,s,v] = @onigRegExp.searchSync(expression)

  color.hsv = [
    parseInt(h.match)
    parseFloat(s.match)
    parseFloat(v.match)
  ]
  color.alpha = 1

# hsva(210,70%,90%,0.7)
Color.addExpression 'hsva', strip("
  hsva#{ps}\\s*
    (#{int})
    #{comma}
    (#{percent})
    #{comma}
    (#{percent})
    #{comma}
    (#{float})
  #{pe}
"), (color, expression) ->
  [_,h,s,v,a] = @onigRegExp.searchSync(expression)

  color.hsv = [
    parseInt(h.match)
    parseFloat(s.match)
    parseFloat(v.match)
  ]
  color.alpha = parseFloat(a.match)


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
  [_,h,s,l,a] = @onigRegExp.searchSync(expression)

  color.rgba = [
    parseFloat(h.match) * 255
    parseFloat(s.match) * 255
    parseFloat(l.match) * 255
    parseFloat(a.match)
  ]

# hwb(210,40%,40%)
Color.addExpression 'hwb', strip("
  hwb#{ps}\\s*
    (#{int})
    #{comma}
    (#{percent})
    #{comma}
    (#{percent})
  #{pe}
"), (color, expression) ->
  [_,h,w,b] = @onigRegExp.searchSync(expression)

  color.hwb = [
    parseInt(h.match)
    parseFloat(w.match)
    parseFloat(b.match)
  ]
  color.alpha = 1


# dodgerblue
colors = Object.keys(Color.namedColors)

colorRegexp = "\\b(?<![\\.\\$@-])(?i)(#{colors.join('|')})(?-i)(?!\\s*[-\\.:=])\\b"

Color.addExpression 'named_colors', colorRegexp, (color, expression) ->
  [_,name] = @onigRegExp.searchSync(expression)

  color.name = name.match
