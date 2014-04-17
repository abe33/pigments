
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

# #000000
Color.addExpression "#(#{hexa}{6})(?!#{hexa})", (color, expression) ->
  [_, hexa] = @onigRegExp.searchSync(expression)

  color.hex = hexa.match

# #000
Color.addExpression "#(#{hexa}{3})(?!#{hexa})", (color, expression) ->
  [_, hexa] = @onigRegExp.searchSync(expression)
  colorAsInt = parseInt(hexa.match, 16)

  color.red = (colorAsInt >> 8 & 0xf) * 17
  color.green = (colorAsInt >> 4 & 0xf) * 17
  color.blue = (colorAsInt & 0xf) * 17

# 0xFF000000
Color.addExpression "0x(#{hexa}{8})(?!#{hexa})", (color, expression) ->
  [_, hexa] = @onigRegExp.searchSync(expression)

  color.hexARGB = hexa.match

# 0x000000
Color.addExpression "0x(#{hexa}{6})(?!#{hexa})", (color, expression) ->
  [_, hexa] = @onigRegExp.searchSync(expression)

  color.hex = hexa.match

# rgb(0,0,0)
Color.addExpression strip("
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

# rgba(0,0,0,1)
Color.addExpression strip("
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

# hsl(0,0%,0%)
Color.addExpression strip("
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

# hsla(0,0%,0%,1)
Color.addExpression strip("
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

# hsv(0,0%,0%)
Color.addExpression strip("
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

# hsva(0,0%,0%,1)
Color.addExpression strip("
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


# vec4(0,0,0,1)
Color.addExpression strip("
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

# black
colors = Object.keys(Color.namedColors)

colorRegexp = "\\b(?<![\\.\\$@-])(?i)(#{colors.join('|')})(?-i)(?![-\\.:=])\\b"

Color.addExpression colorRegexp, (color, expression) ->
  [_,name] = @onigRegExp.searchSync(expression)

  color.name = name.match
