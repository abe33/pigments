{OnigRegExp} = require 'oniguruma'

module.exports =
class ColorExpression
  constructor: (@regexp, @handle) ->
    @onigRegExp = new OnigRegExp("^#{@regexp}$")

  canHandle: (expression) -> @onigRegExp.testSync expression
  search: (text, start=0) ->
    results = undefined
    re = new OnigRegExp(@regexp)
    if match = re.searchSync(text, start)
      [match] = match

      range = [match.start, match.end]
      results =
        range: range
        match: text[range[0]...range[1]]

    results
