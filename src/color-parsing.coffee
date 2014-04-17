Mixin = require 'mixto'
{OnigRegExp} = require 'oniguruma'

module.exports =
class ColorParsing extends Mixin
  # The {Array} where color expression handlers are stored
  @colorExpressions: []

  # The {Array} where color operation handlers are stored
  @colorOperations: []

  # Public: Registers a color expression into the {Color} class.
  # The function will create an expression handler with the passed-in
  # arguments.
  #
  # regexp - A {RegExp} that matches the color notation. The
  #          expression can capture groups that will be used later in the
  #          color parsing phase
  # handle - A {Function} that takes a {Color} to modify and the {String}
  #          that matched during the lookup phase
  @addExpression: (regexp, handle=->) ->
    @colorExpressions.push
      regexp: regexp
      onigRegExp: new OnigRegExp("^#{regexp}$")
      handle: handle
      canHandle: (expression) -> @onigRegExp.testSync expression

  @addOperation: (begin, args..., end, handle=->) ->
    constructor = this
    @colorOperations.push
      begin: begin
      end: end
      args: args
      onigBegin: new OnigRegExp(begin)
      onigEnd: new OnigRegExp(end)
      handle: handle
      search: (text, start=0) ->
        results = undefined
        argMatches = []

        if startMatch = @onigBegin.searchSync(text, start)
          start = startMatch[0].end
          for arg in @args
            if arg is constructor
              argMatch = constructor.searchColor(text, start)
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

      canHandle: (expression) -> @search(expression)?

  @searchColor: (text, start) ->
    found = @searchOperation(text, start)
    found = @searchExpression(text, start) unless found?
    found

  @searchExpression: (text, start=0) ->
    results = undefined
    @colorExpressions.some (expr) ->
      re = new OnigRegExp(expr.regexp)
      if match = re.searchSync(text, start)
        [match] = match

        range = [match.start, match.end]
        results =
          range: range
          match: text[range[0]...range[1]]
        return true

      false

    results

  @searchOperation: (text, start=0) ->
    results = undefined
    @colorOperations.some (operation) ->
      return true if results = operation.search(text, start)

    results

  parseExpression: (colorExpression) ->
    @constructor.colorExpressions.some (expr) =>
      if expr.canHandle(colorExpression)
        expr.handle(this, colorExpression)
        return true

      false

  parseOperation: (colorExpression) ->
    @constructor.colorOperations.some (operation) =>
      if results = operation.search(colorExpression)
        operation.handle(this, [1,1])
        return true

      false
