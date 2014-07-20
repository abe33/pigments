
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
    (#{intOrPercent}|#{variables})
    #{comma}
    (#{intOrPercent}|#{variables})
    #{comma}
    (#{intOrPercent}|#{variables})
  #{pe}
"), (color, expression, fileVariables) ->
  [_,r,_,_,g,_,_,b] = @onigRegExp.searchSync(expression)

  color.red = parseIntOrPercent(r.match, fileVariables)
  color.green = parseIntOrPercent(g.match, fileVariables)
  color.blue = parseIntOrPercent(b.match, fileVariables)
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
  [_,r,_,_,g,_,_,b,_,_,a] = @onigRegExp.searchSync(expression)

  color.red = parseIntOrPercent(r.match, fileVariables)
  color.green = parseIntOrPercent(g.match, fileVariables)
  color.blue = parseIntOrPercent(b.match, fileVariables)
  color.alpha = parseFloat(a.match, fileVariables)

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
  [_,h,_,s,_,l] = @onigRegExp.searchSync(expression)

  color.hsl = [
    parseInt(h.match, fileVariables)
    parseFloat(s.match, fileVariables)
    parseFloat(l.match, fileVariables)
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
  [_,h,_,s,_,l,_,a] = @onigRegExp.searchSync(expression)

  color.hsl = [
    parseInt(h.match,fileVariables)
    parseFloat(s.match,fileVariables)
    parseFloat(l.match,fileVariables)
  ]
  color.alpha = parseFloat(a.match,fileVariables)

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
  [_,h,_,s,_,v] = @onigRegExp.searchSync(expression)

  color.hsv = [
    parseInt(h.match, fileVariables)
    parseFloat(s.match, fileVariables)
    parseFloat(v.match, fileVariables)
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
  [_,h,_,s,_,v,_,a] = @onigRegExp.searchSync(expression)

  color.hsv = [
    parseInt(h.match, fileVariables)
    parseFloat(s.match, fileVariables)
    parseFloat(v.match, fileVariables)
  ]
  color.alpha = parseFloat(a.match, fileVariables)


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
    (#{int}|#{variables})
    #{comma}
    (#{percent}|#{variables})
    #{comma}
    (#{percent}|#{variables})
    (#{comma}(#{float}|#{variables}))?
  #{pe}
"), (color, expression, fileVariables) ->
  [_,h,_,w,_,b,_,_,a] = @onigRegExp.searchSync(expression)

  color.hwb = [
    parseInt(h.match, fileVariables)
    parseFloat(w.match, fileVariables)
    parseFloat(b.match, fileVariables)
  ]
  color.alpha = if a.match.length then parseFloat(a.match, fileVariables) else 1

# gray(50%)
# The priority is set to 1 to make sure that it appears before named colors
Color.addExpression 'gray', strip("
  gray#{ps}\\s*
    (#{percent})
    (#{comma}(#{float}))?
  #{pe}"), 1, (color, expression) ->
  [_,p,_,a] = @onigRegExp.searchSync(expression)

  p = parseFloat(p.match) / 100 * 255
  color.rgb = [p, p, p]
  color.alpha = if a.match.length then parseFloat(a.match) else 1

# dodgerblue
colors = Object.keys(Color.namedColors)

colorRegexp = "\\b(?<![\\.\\$@-])(?i)(#{colors.join('|')})(?-i)(?!\\s*[-\\.:=])\\b"

Color.addExpression 'named_colors', colorRegexp, (color, expression) ->
  [_,name] = @onigRegExp.searchSync(expression)

  color.name = name.match
