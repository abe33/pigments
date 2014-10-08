Mixin = require 'mixto'
_ = require 'underscore-plus'
Q = require 'q'

{namePrefixes} = require './regexes'
ColorExpression = require './color-expression'
ColorOperation = require './color-operation'

# Internal: The {ColorParsing} mixin provides instances and class methods
# to register color expressions and operations and to parse these expressions
# into {Color}s.
module.exports =
class ColorParsing extends Mixin
  ASYNC_THRESHOLD = 40

  # The {Object} where color expression handlers are stored
  @colorExpressions: {}

  # Public: Registers a color expression into the {Color} class.
  # The function will create an expression handler with the passed-in
  # arguments.
  #
  # name - A {String} to identify the expression
  # regexp - An {OnigRegExp} {String} that matches the color notation. The
  #          expression can capture groups that will be used later in the
  #          color parsing phase
  # handle - A {Function} that takes a {Color} to modify and the {String}
  #          that matched during the lookup phase
  @addExpression: (name, regexp, priority=0, handle=->) ->
    [priority, handle] = [0, priority] if typeof priority is 'function'
    @colorExpressions[name] = new ColorExpression(name, regexp, handle, priority)

  # Public: Removes an expression using the passed-in `name`.
  #
  # name - A {String} identifying the expression to remove
  @removeExpression: (name) -> delete @colorExpressions[name]

  # Public: Scans the passed-in {Buffer} for {Color}s.
  #
  # buffer - The {Buffer} object into which performing the search
  # callback - An optional {Function} that will be called for each match
  #            in the buffer with the result {Object} of the match.
  #
  # Returns a {Promise} whose value will be an {Array} containing all the
  # found matches.
  @scanBufferForColors: (buffer, variables=null, callback) ->
    @scanBufferForColorsInRange(buffer, [[0, 0], [Infinity, Infinity]], variables, callback)

  # Public: Scans the passed-in {Buffer} for {Color}s within the given
  # {Range}.
  #
  # buffer - The {Buffer} object into which performing the search
  # range - The {Range} into which searching for colors.
  # callback - An optional {Function} that will be called for each match
  #            in the buffer with the result {Object} of the match.
  #
  # Returns a {Promise} whose value will be an {Array} containing all the
  # found matches.
  @scanBufferForColorsInRange: (buffer, range=[[0, 0], [Infinity, Infinity]],  variables=null, callback=->) ->
    throw new Error 'Missing buffer' unless buffer?
    [callback, variables] = [variables] if typeof variables is 'function'

    Range = buffer.constructor.Range

    defer = Q.defer()
    range = Range.fromObject(range)

    start = buffer.characterIndexForPosition(range.start)
    end = buffer.characterIndexForPosition(range.end)
    bufferText = buffer.getText()

    variablesPromise = if variables?
      Q.fcall -> variables
    else
      @scanBufferForVariablesInRange(buffer, range)

    Color = this
    variablesPromise
    .then (variablesMap) =>
      variables = (k for k of variablesMap)

      .filter (s) ->
        variablesMap[s].isColor
      .map (s) -> _.escapeRegExp(s)

      if variables.length > 0
        paletteRegexpString = "(#{namePrefixes})(" + variables.join('|') + ')(?!_|-|\\d|[ \\t]*[\\.:=])'
        paletteRegexp = new RegExp(paletteRegexpString)

        Color.addExpression 'variables', paletteRegexpString, 1, (color, expr) ->
          [d,d,name] = paletteRegexp.exec(expr)
          color.rgba = new Color(variablesMap[name].value, variablesMap).rgba
          color.colorExpression = name

      results = []
      startTime = new Date
      iterator = (result) =>
        if result?
          [matchStart, matchEnd] = result.range

          if matchEnd <= end
            result.color = new Color(result.match, variablesMap)
            # HACK: Color expressions like named colors may match one
            # character before the real color, but they ensure that the
            # colorExpression doesn't contains it. By index the offset
            # we end with the proper range in the buffer.
            result.range[0] += result.match.indexOf(result.color.colorExpression)

            result.bufferRange = new Range(
              buffer.positionForCharacterIndex(result.range[0]),
              buffer.positionForCharacterIndex(result.range[1]),
            )
            results.push result
            callback(result)
            start = matchEnd

            time = new Date

            if time - startTime < ASYNC_THRESHOLD
              @searchColor bufferText, start, iterator
            else
              requestAnimationFrame =>
                startTime = new Date
                @searchColor bufferText, start, iterator
          else
            defer.resolve if results.length > 0 then results else undefined
            Color.removeExpression('variables')
        else
          defer.resolve if results.length > 0 then results else undefined
          Color.removeExpression('variables')

      @searchColor bufferText, start, iterator

    .fail (reason) ->
      defer.reject(reason)

    defer.promise

  # Public: Searches for a {Color} in `text` synchronously using
  # all the expressions and operations registered in the {Color} class.
  #
  # text - The {String} into which performing the search.
  # start - An optional {Integer} that set the starting index for
  #         the search. Defaults to `0`
  #
  # Returns an {Object} with the following properties:
  #
  # match - The first color {String} found in the {String}
  # range - An {Array} containing the character index of the start
  #         and end of the matching {String}
  # argMatches - An {Array} with the arguments matches when the found
  #              color is an operation.
  @searchColorSync: (text, start=0) ->
    @searchExpressionSync(text, start)


  # Public: Searches for a color expression in `text` synchronously using
  # the ones registered previously into the {Color} class.
  #
  # text - A {String} into which performing the search
  # start - An optional {Integer} that set the starting index for
  #         the search. Defaults to `0`
  #
  # Returns an {Object} with the following properties:
  #
  # match - The first color {String} found in the {String}
  # range - An {Array} containing the character index of the start
  #         and end of the matching {String}
  @searchExpressionSync: (text, start=0) ->
    ore = new RegExp(@colorRegExp(), 'g')
    ore.lastIndex = start
    if match = ore.exec(text)
      matchText = match[0]
      {lastIndex} = ore

      {
        match: matchText
        range: [lastIndex - matchText.length, lastIndex]
      }


  # Public: Searches for a {Color} in `text` asynchronously using
  # all the expressions and operations registered in the {Color} class.
  #
  # text - The {String} into which performing the search.
  # start - An optional {Integer} that set the starting index for
  #         the search. Defaults to `0`
  # callback - An optional {Function} that will be called with the
  #            match results {Object} or `undefined` if no matches
  #            was found.
  #
  # Returns a {Promise} whose value is the match {Object}, containing:
  #
  # match - The first color {String} found in the {String}
  # range - An {Array} containing the character index of the start
  #         and end of the matching {String}
  # argMatches - An {Array} with the arguments matches when the found
  #              color is an operation.
  @searchColor: (text, start=0, callback=->) ->
    @searchExpression(text, start, callback)

  # Public: Searches for a {Color} in `text` asynchronously using
  # all the expressions registered in the {Color} class.
  #
  # text - The {String} into which performing the search.
  # start - An optional {Integer} that set the starting index for
  #         the search. Defaults to `0`
  # callback - An optional {Function} that will be called with the
  #            match results {Object} or `undefined` if no matches
  #            was found.
  #
  # Returns a {Promise} whose value is the match {Object}, containing:
  #
  # match - The first color {String} found in the {String}
  # range - An {Array} containing the character index of the start
  #         and end of the matching {String}
  @searchExpression: (text, start=0, callback=->) ->
    defer = Q.defer()
    ore = new RegExp(@colorRegExp(), 'g')
    ore.lastIndex = start
    if match = ore.exec text
      matchText = match[0]
      {lastIndex} = ore

      result = {
        match: matchText
        range: [lastIndex - matchText.length, lastIndex]
      }
      callback result
      defer.resolve result
    else
      callback()
      defer.reject()

    defer.promise

  # Internal: Parse a color expression and modify this {Color} object
  # accordingly.
  #
  # colorExpression - A {String} to parse
  parseExpression: (colorExpression, fileVariables={}) ->
    for expr in @constructor.sortedColorExpressions()
      if expr.canHandle(colorExpression)
        expr.handle(this, colorExpression, fileVariables)
        return
