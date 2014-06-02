Mixin = require 'mixto'
Q = require 'q'
{OnigRegExp} = require 'oniguruma'

# Internal: The {ColorParsing} mixin provides instances and class methods
# to register color expressions and operations and to parse these expressions
# into {Color}s.
module.exports =
class ColorVariablesParsing extends Mixin
  @variableExpressions: {}

  @addVariableExpression: (name, key, separator, value) -> @variableExpressions[name] = {key, separator, value}

  @removeVariableExpression: (name) -> delete @variableExpressions[name]

  @scanBufferForColorVariables: (buffer, callback) ->
    @scanBufferForColorVariablesInRange(buffer, [[0, 0], [Infinity, Infinity]], callback)

  @scanBufferForColorVariablesInRange: (buffer, range, callback) ->
    hrow new Error 'Missing buffer' unless buffer?
    Range = buffer.constructor.Range

    defer = Q.defer()
    range = Range.fromObject(range)

    start = buffer.characterIndexForPosition(range.start)
    end = buffer.characterIndexForPosition(range.end)
    bufferText = buffer.getText()[start..end]
    re = @getVariableExpressionsRegexp()

    searchOccurences = (str, cb, start=0) ->
      re.search str, start, (err, match) ->
        defer.reject(err) if err?


        if match?
          [_, key, _, value] = match
          if @constructor.canHandle?(value)
            cb?(match)

          searchOccurences(str, cb, match[0].end)
        else
          defer.resolve()

    searchOccurences bufferText, callback

    defer.promise

  @getVariableExpressionsRegexp: ->
    keys = []
    values = []
    separators = []

    for k,{key, separator, value} of @variableExpressions
      keys.push key
      values.push value
      separators.push separator

    regex = "(#{keys.join '|'})(#{separators.join '|'})(#{values.join '|'})"
    new OnigRegExp(regex)
