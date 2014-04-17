Mixin = require 'mixto'
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
  @searchColor: (text, start=0) ->
    found = @searchOperation(text, start)
    found = @searchExpression(text, start) unless found?
    found

  # Public: Searches for a color expression in `text` using the ones registered
  # previously into the {Color} class.
  #
  # teext,
  @searchExpression: (text, start=0) ->
    results = undefined
    @colorExpressions.some (expr) ->
      return true if results = expr.search(text, start)

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
        args = results.argMatches.map (res, i) =>
          argType = operation.args[i]
          if argType is @constructor
            new @constructor res.match
          else
            res.match

        operation.handle(this, args)
        return true

      false
