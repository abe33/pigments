Mixin = require 'mixto'
Q = require 'q'
{OnigRegExp} = require 'oniguruma'

ColorExpression = require './color-expression'
ColorOperation = require './color-operation'

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
  # regexp - An {OnigRegExp} {String} that matches the color notation. The
  #          expression can capture groups that will be used later in the
  #          color parsing phase
  # handle - A {Function} that takes a {Color} to modify and the {String}
  #          that matched during the lookup phase
  @addExpression: (regexp, handle=->) ->
    @colorExpressions.push new ColorExpression(regexp, handle)

  # Public: Registers a color operation into the {Color} class.
  # The function will create an operation handler with the passed-in
  # arguments.
  #
  # begin - An {OnigRegExp} {String} that matches the start of the operation.
  # args... - A list of arguments for the operation. An argument can be either
  #           a reference to the {Color} class or an {OnigRegExp} {String}.
  #           When {Color} is passed, the argument will any expression or
  #           operation registered in the {Color} class.
  # end - An {OnigRegExp} {String} that matches the end of the operation
  # handle - A {Function} that takes a {Color} to modify and an array of the
  #          arguments passed to the operation. When the registered argument is
  #          {Color}, the argument value will be parsed automatically as
  #          a {Color}.
  @addOperation: (begin, args..., end, handle=->) ->
    @colorOperations.push new ColorOperation(begin, args, end, handle, this)

  @scanBufferForColors: (buffer, callback) ->
    @scanBufferForColorsInRange(buffer,range=[[0, 0], [Infinity, Infinity]], callback)

  # Public: Scans the passed-in {Buffer} for {Color}s within the given
  # {Range}.
  #
  # buffer - The {Buffer} object into which performing the search
  # range - The {Range} into which searching for colors.
  # callback - An optional {Function} that will be called for each match
  #            in the buffer with the result {Object} of the match.
  #
  # Returns a promise whose value will be an {Array} containing all the
  # found matches.
  @scanBufferForColorsInRange: (buffer, range=[[0, 0], [Infinity, Infinity]], callback=->) ->
    throw new Error 'Missing buffer' unless buffer?
    Range = buffer.constructor.Range

    defer = Q.defer()
    range = Range.fromObject(range)

    start = buffer.characterIndexForPosition(range.start)
    end = buffer.characterIndexForPosition(range.end)
    bufferText = buffer.getText()

    results = []
    iterator = (result) =>
      if result?
        [matchStart, matchEnd] = result.range

        if matchEnd <= end
          result.bufferRange = new Range(
            buffer.positionForCharacterIndex(result.range[0]),
            buffer.positionForCharacterIndex(result.range[1]),
          )
          results.push result
          callback(result)
          start = matchEnd
          @searchColor bufferText, start, iterator
        else
          defer.resolve if results.length > 0 then results else undefined

      else
        defer.resolve if results.length > 0 then results else undefined

    @searchColor bufferText, start, iterator

    defer.promise

  # Public: Searches for a {Color} in `text` using all the expressions and
  # operations registered in the {Color} class.
  #
  # text - The {String} into which performing the search.
  # start - An optional {Integer} that set the starting index for the search.
  #         Defaults to `0`
  #
  # Returns an object with the following properties:
  #
  # match - The first color {String} found in the {String}
  # range - An {Array} containing the character index of the start and end
  #         of the matching {String}
  # argMatches - An {Array} with the arguments matches when the found color
  #              is an operation.
  @searchColorSync: (text, start=0) ->
    foundOp = @searchOperationSync(text, start)
    foundExpr = @searchExpressionSync(text, start)

    if foundOp? and foundExpr?
      if foundOp.range[0] < foundExpr.range[0]
        foundOp
      else
        foundExpr
    else if foundOp?
      foundOp
    else if foundExpr?
      foundExpr
    else
      undefined

  # Public: Searches for a color expression in `text` using the ones registered
  # previously into the {Color} class.
  #
  # teext,
  @searchExpressionSync: (text, start=0) ->
    results = undefined
    @colorExpressions.some (expr) ->
      return true if results = expr.searchSync(text, start)

    results

  @searchOperationSync: (text, start=0) ->
    results = undefined
    @colorOperations.some (operation) ->
      return true if results = operation.searchSync(text, start)

    results

  @searchColor: (text, start=0, callback=->) ->
    foundOp = undefined
    foundExpr = undefined

    @searchOperation(text, start)
    .then (result) =>
      foundOp = result
      @searchExpression(text, start)
    .then (result) ->
      foundExpr = result

      result = if foundOp? and foundExpr?
        if foundOp.range[0] < foundExpr.range[0]
          foundOp
        else
          foundExpr
      else if foundOp?
        foundOp
      else if foundExpr?
        foundExpr
      else
        undefined

      callback(result)
      result

  @searchExpression: (text, start=0, callback=->) ->
    promise = Q.all @colorExpressions.map (expr) -> expr.search(text, start)

    promise.then (results) ->
      result = results.filter((el) -> el?)[0]
      callback(result)
      result

  @searchOperation: (text, start=0, callback=->) ->
    promise = Q.all @colorOperations.map (op) -> op.search(text, start)

    promise.then (results) ->
      result = results.filter((el) -> el?)[0]
      callback(result)
      result


  parseExpression: (colorExpression) ->
    @constructor.colorExpressions.some (expr) =>
      if expr.canHandle(colorExpression)
        expr.handle(this, colorExpression)
        return true

      false

  parseOperation: (colorExpression) ->
    @constructor.colorOperations.some (operation) =>
      if results = operation.searchSync(colorExpression)
        args = results.argMatches.map (res, i) =>
          argType = operation.args[i]
          if argType is @constructor
            new @constructor res.match
          else
            res.match

        operation.handle(this, args)
        return true

      false
