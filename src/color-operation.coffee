{OnigRegExp} = require 'oniguruma'

module.exports =
class ColorOperation
  constructor: (@begin, @args, @end, @handle, @Color) ->
    @onigBegin = new OnigRegExp(@begin)
    @onigEnd = new OnigRegExp(@end)

  canHandle: (expression) -> @search(expression)?
  searchSync: (text, start=0) ->
    results = undefined
    argMatches = []

    if startMatch = @onigBegin.searchSync(text, start)
      start = startMatch[0].end
      for arg in @args
        if arg is @Color
          argMatch = @Color.searchColorSync(text, start)
        else
          onigRegex = new OnigRegExp(arg)
          match = onigRegex.searchSync(text, start)
          return unless match?

          range = [match[0].start, match[0].end]
          argMatch =
            range: range
            match: text[range[0]..range[1]]

        return unless argMatch?
        [_, start] = argMatch.range
        argMatches.push argMatch

      endMatch = @onigEnd.searchSync(text, start)
      return unless endMatch?

      range = [startMatch[0].start, endMatch[0].end]
      results =
        range: range
        match: text[range[0]...range[1]]
        argMatches: argMatches

    results
