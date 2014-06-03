Q = require 'q'
{OnigRegExp} = require 'oniguruma'

# Internal: The {ColorExpression} class represents a color {String}
# representation. The expression is created using an {OnigRegExp} string
# and a {Function} to handle matches.
module.exports =
class ColorExpression
  # Public: Creates the expression.
  #
  # name - A {String that identify the expression}
  # regexp - The oniguruma regexp {String} that match the expression
  # handle - A {Function} that will be called to modify a {Color} accordingly
  #          to a {String} previsouly matched by this expression.
  # priority - A {Number} to priorize an expression over others. The greater
  #            the value, the sooner it will be evaluated.
  constructor: (@name, @regexp, @handle, @priority=0) ->
    @onigRegExp = new OnigRegExp("^#{@regexp}$")

  # Public: Returns `true` if the current {ColorExpression} can handle
  # the passed-in expression {String}.
  #
  # expression - A {String} to test
  #
  # Returns `true` if the current {ColorExpression} can handle
  # the passed-in expression.
  canHandle: (expression) -> @onigRegExp.testSync expression

  # Public: Performs a synchronous search for this expression into the
  # passed-in `text` {String}.
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
  searchSync: (text, start=0) ->
    results = undefined
    re = new OnigRegExp(@regexp)
    if match = re.searchSync(text, start)
      [match] = match

      range = [match.start, match.end]
      results =
        range: range
        match: text[range[0]...range[1]]

    results

  # Public: Performs an asynchronous search for this expression into the
  # passed-in `text` {String}.
  #
  # text - The {String} into which performing the search.
  # start - An optional {Integer} that set the starting index for
  #         the search. Defaults to `0`
  # callback - An optional {Function} that will be called with the
  #            match results {Object} or `undefined` if no matches
  #            was found.
  #
  # Returns a {Promise} whose value is the result {Object}, containing:
  #
  # match - The first color {String} found in the {String}
  # range - An {Array} containing the character index of the start
  #         and end of the matching {String}
  search: (text, start=0, callback=->) ->
    defer = Q.defer()

    re = new OnigRegExp(@regexp)
    re.search text, start, (err, match) ->
      unless match?
        defer.resolve()
        callback()
        return

      [match] = match

      range = [match.start, match.end]
      results =
        range: range
        match: text[range[0]...range[1]]

      defer.resolve(results)
      callback(results)

    defer.promise
