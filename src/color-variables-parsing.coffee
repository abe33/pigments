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

  @scanBufferForVariables: (buffer, callback) ->
    @scanBufferForVariablesInRange(buffer, [[0, 0], [Infinity, Infinity]], callback)

  @scanBufferForVariablesInRange: (buffer, range, callback) ->
    throw new Error 'Missing buffer' unless buffer?
    Range = buffer.constructor.Range

    defer = Q.defer()
    range = Range.fromObject(range)

    bufferStart = buffer.characterIndexForPosition(range.start)
    bufferEnd = buffer.characterIndexForPosition(range.end)
    bufferText = buffer.getText()[bufferStart..bufferEnd]
    re = @getVariableExpressionsRegexp()

    results = {}

    searchOccurences = (str, cb, start=0) =>
      re.search str, start, (err, match) =>
        defer.reject(err) if err?

        if match? and match[0].match isnt ''
          [key, value] = @extractVariableElements(match[0].match, buffer)
          start = buffer.positionForCharacterIndex(bufferStart + match[0].start)
          end = buffer.positionForCharacterIndex(bufferStart + match[0].end)
          range = [
            [start.row, start.column]
            [end.row, end.column]
          ]
          if @canHandle(value)
            results[key] = {value, range, isColor: true}
            cb?(match)
          else
            results[key] = {value, range, isColor: false}
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
