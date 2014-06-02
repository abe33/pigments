Mixin = require 'mixto'
Q = require 'q'
{OnigRegExp} = require 'oniguruma'

# Internal: The {ColorParsing} mixin provides instances and class methods
# to register color expressions and operations and to parse these expressions
# into {Color}s.
module.exports =
class ColorVariablesParsing extends Mixin
  @variableExpressions: {}

  @addVariableExpression: (name, key, separator, value, endLine) -> @variableExpressions[name] = {key, separator, value, endLine}

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

    results = {}

    searchOccurences = (str, cb, start=0) =>
      re.search str, start, (err, match) =>
        defer.reject(err) if err?

        if match?
          [_, key, _, value] = match

          if @canHandle(value.match)
            results[key.match] = value.match
            cb?(match)

          searchOccurences(str, cb, match[0].end)
        else
          defer.resolve(results)

    searchOccurences bufferText, callback

    defer.promise

  @getVariableExpressionsRegexp: ->
    keys = []
    values = []
    separators = []
    endLines = []

    for k,{key, separator, value, endLine} of @variableExpressions
      keys.push key
      values.push value
      separators.push separator
      endLines.push endLine

    regex = "(#{keys.join '|'})(#{separators.join '|'})(#{values.join '|'})(#{endLines.join '|'})"
    new OnigRegExp(regex)
