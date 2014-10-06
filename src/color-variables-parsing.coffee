Mixin = require 'mixto'
Q = require 'q'

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

    range = Range.fromObject(range)

    hasResults = false
    bufferStart = buffer.characterIndexForPosition(range.start)
    bufferEnd = buffer.characterIndexForPosition(range.end)
    bufferText = buffer.getText()[bufferStart..bufferEnd]
    re = @getVariableExpressionsRegexp()

    results = {}

    re.lastIndex = bufferStart
    while match = re.exec bufferText
      hasResults = true
      {lastIndex} = re
      break if lastIndex > bufferEnd

      res = match[0]
      [key, value] = @extractVariableElements(res)
      start = buffer.positionForCharacterIndex(lastIndex - res.length)
      end = buffer.positionForCharacterIndex(lastIndex)
      range = [
        [start.row, start.column]
        [end.row, end.column]
      ]
      if @canHandle(value) or (results[value]? and results[value].isColor)
        results[key] = {value, range, isColor: true}
        callback?(match)
      else
        results[key] = {value, range, isColor: false}
        callback?(match)

    Q.fcall -> results

  @extractVariableElements: (string) ->
    for k,re of @variableExpressions
      ore = new RegExp(re)
      m = ore.exec(string)
      if m?
        [_, key, value] = m
        return [key, value]

    null


  @getVariableExpressionsRegexp: ->
    regex = (v for k,v of @variableExpressions).join('|')
    new RegExp("(#{regex})", 'gm')
