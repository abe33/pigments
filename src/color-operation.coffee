Q = require 'q'
{OnigRegExp} = require 'oniguruma'

{comma} = require './regexes'

commaRegexp = new OnigRegExp('\\G' + comma)

module.exports =
class ColorOperation
  constructor: (@begin, @args, @end, @handle, @Color) ->
    @onigBegin = new OnigRegExp(@begin)
    @onigEnd = new OnigRegExp('\\G' + @end)

  canHandle: (expression) -> @search(expression)?

  searchSync: (text, start=0) ->
    while startMatch = @onigBegin.searchSync(text, start)
      argMatches = []
      start = startMatch[0].end
      for arg,i in @args
        if arg is @Color
          argMatch = @Color.searchColorSync(text, start)
        else
          onigRegex = new OnigRegExp('\\G' + arg)
          match = onigRegex.searchSync(text, start)
          break unless match?

          range = [match[0].start, match[0].end]
          argMatch =
            range: range
            match: text[range[0]...range[1]]

        break unless argMatch?
        break if argMatch.range[0] isnt start
        [_, start] = argMatch.range
        argMatches.push argMatch

        if i isnt @args.length - 1
          commaMatch = commaRegexp.searchSync(text, start)
          break unless commaMatch?
          start = commaMatch[0].end

      continue if argMatches.length isnt @args.length

      endMatch = @onigEnd.searchSync(text, start)
      continue unless endMatch?

      range = [startMatch[0].start, endMatch[0].end]
      return {
        range: range
        match: text[range[0]...range[1]]
        argMatches: argMatches
      }

    undefined

  search: (text, start=0, callback=->) ->
    defer = Q.defer()

    setImmediate =>
      res = @searchSync(text, start)
      defer.resolve(res)
      callback(res)

    defer.promise
