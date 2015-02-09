Mixin = require 'mixto'
Q = require 'q'

# Internal: The {ColorParsing} mixin provides instances and class methods
# to register color expressions and operations and to parse these expressions
# into {Color}s.
module.exports =
class ColorVariablesParsing extends Mixin
  @variableExpressions: {}

  @addVariableExpression: (name, regexp, block) ->
    @variableExpressions[name] = {regexp, block}

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
    solver =
      appendResult: ([key, value, startIndex, lastIndex]) =>
        start = buffer.positionForCharacterIndex(startIndex)
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

    re.lastIndex = bufferStart
    while match = re.exec bufferText
      hasResults = true

      {lastIndex} = re
      res = match[0]
      startIndex = lastIndex - res.length
      break if lastIndex > bufferEnd

      re.lastIndex = @extractVariableElements(res, startIndex, lastIndex, solver)

    Q.fcall -> results

  @extractVariableElements: (string, startIndex, lastIndex, solver) ->
    for k,{regexp, block} of @variableExpressions
      re = new RegExp(regexp)
      m = re.exec(string)

      if m?
        if block?
          return block(m, startIndex, lastIndex, solver)
        else
          [_, key, value] = m
          solver.appendResult([key, value, startIndex, lastIndex])
          return lastIndex


  @getVariableExpressionsRegexp: ->
    regex = (v.regexp for k,v of @variableExpressions).join('|')
    new RegExp("(#{regex})", 'gm')
