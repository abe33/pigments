Mixin = require 'mixto'
Q = require 'q'
{OnigRegExp} = require 'oniguruma'

# Internal: The {ColorParsing} mixin provides instances and class methods
# to register color expressions and operations and to parse these expressions
# into {Color}s.
module.exports =
class ColorVariablesParsing extends Mixin
  @variableExpressions: {}

  @addVariableExpression: (name, regexp) ->
    @variableExpressions[name] = regexp

  @removeVariableExpression: (name) ->
    delete @variableExpressions[name]

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

        if match? and match[0].match isnt ''
          [key, value] = @extractVariableElements(match[0].match, buffer)
          start = buffer.positionForCharacterIndex(match[0].start)
          end = buffer.positionForCharacterIndex(match[0].end)
          range = [
            [start.row, start.column]
            [end.row, end.column]
          ]
          if @canHandle(value)
            results[key] = {value, range}
            cb?(match)

          searchOccurences(str, cb, match[0].end)
        else
          defer.resolve(results)

    searchOccurences bufferText, callback

    defer.promise

  @extractVariableElements: (string) ->
    for k,re of @variableExpressions
      ore = new OnigRegExp(re)
      m = ore.searchSync(string)
      if m?
        [_, key, value] = m
        return [key.match, value.match]

    null


  @getVariableExpressionsRegexp: ->
    regex = (v for k,v of @variableExpressions).join('|')
    new OnigRegExp("(#{regex})")
