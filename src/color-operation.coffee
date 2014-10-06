Q = require 'q'

{comma} = require './regexes'

commaRegexp = new RegExp('^' + comma)

# Internal: The {ColorOperation} class represents a color operation {String}
# representation.
module.exports =
class ColorOperation
  # Public: Creates a {ColorOperation}.
  #
  # name - A {String} that identify the operation
  # begin - An {RegExp} {String} that matches the start of the operation.
  # args... - A list of arguments for the operation. An argument can be either
  #           a reference to the {Color} class or an {RegExp} {String}.
  #           When {Color} is passed, the argument will search for any operation
  #           forms registered in the {Color} class.
  # end - An {RegExp} {String} that matches the end of the operation
  # handle - A {Function} that takes a {Color} to modify and an array of the
  #          arguments passed to the operation. When the registered argument is
  #          {Color}, the argument value will be parsed automatically as
  #          a {Color}.
  constructor: (@name, @begin, @args, @end, @handle, @Color) ->
    @onigBegin = new RegExp(@begin)
    @onigEnd = new RegExp('^' + @end)

  # Public: Returns `true` if the current {ColorOperation} can handle
  # the passed-in `operation` {String}.
  #
  # operation - A {String} to test
  #
  # Returns `true` if the current {ColorOperation} can handle
  # the passed-in operation.
  canHandle: (operation) -> @search(operation)?

  # Public: Performs an synchronous search for this operation into the
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
  # argMatches - An {Array} containing the submatches for the operation
  #              arguments.
  searchSync: (text, start=0) ->
    while startMatch = @onigBegin.searchSync(text, start)
      argMatches = []
      start = startMatch[0].end
      for arg,i in @args
        if arg is @Color
          argMatch = @Color.searchColorSync(text, start)
        else
          onigRegex = new RegExp('^' + arg)
          match = onigRegex.searchSync(text, start)
          break unless match?

          range = [match[0].start, match[0].end]
          argMatch =
            range: range
            match: text[range[0]...range[1]]

        break unless argMatch?
        break if argMatch.range[0] isnt start
        [_, start] = argMatch.range
        argMatches.push argMatch

        if i isnt @args.length - 1
          commaMatch = commaRegexp.searchSync(text, start)
          break unless commaMatch?
          start = commaMatch[0].end

      continue if argMatches.length isnt @args.length

      endMatch = @onigEnd.searchSync(text, start)
      continue unless endMatch?

      range = [startMatch[0].start, endMatch[0].end]
      return {
        range: range
        match: text[range[0]...range[1]]
        argMatches: argMatches
      }

    undefined

  # Public: Performs an asynchronous search for this operation into the
  # passed-in `text` {String}.
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
  # argMatches - An {Array} containing the submatches for the operation
  #              arguments.
  search: (text, start=0, callback=->) ->

    verifyArgument = (arg, isLast=false) => =>
      defer = Q.defer()

      if arg is @Color
        @Color.searchColor text, start, (argMatch) ->
          return defer.reject("Can't find Color argument at #{start}") unless argMatch?

          [_, start] = argMatch.range

          unless isLast
            commaRegexp.search text, start, (err, commaMatch) ->
              return defer.reject(err) if err?
              return defer.reject("Can't find comma at #{start}") unless commaMatch?
              start = commaMatch[0].end
              defer.resolve(argMatch)

          else
            defer.resolve(argMatch)

      else
        onigRegex = new RegExp('^' + arg)
        onigRegex.search text, start, (err, match) ->
          return defer.reject(err) if err?
          return defer.reject("Can't find argument '#{arg}' at #{start}") unless match?

          range = [match[0].start, match[0].end]
          argMatch =
            range: range
            match: text[range[0]...range[1]]

          [_, start] = argMatch.range

          unless isLast
            commaRegexp.search text, start, (err, commaMatch) ->
              return defer.reject(err) if err?
              return defer.reject("Can't find comma at #{start}") unless commaMatch?

              start = commaMatch[0].end
              defer.resolve(argMatch)

          else
            defer.resolve(argMatch)

      defer.promise

    defer = Q.defer()
    results = undefined
    iterate = =>
      @onigBegin.search text, start, (err, startMatch) =>
        argMatches = []
        if startMatch?
          start = startMatch[0].end

          p = Q.fcall(->)

          for arg,i in @args
            p = p
            .then(verifyArgument(arg, i is @args.length - 1))
            .then (argMatch) ->
              argMatches.push argMatch

          p
          .then (results) =>
            @onigEnd.search text, start, (err, endMatch) ->
              return defer.reject(err) if err?
              return defer.reject("Can't find end match at #{start}") unless endMatch?

              range = [startMatch[0].start, endMatch[0].end]
              defer.resolve {
                range: range
                match: text[range[0]...range[1]]
                argMatches: argMatches
              }

          .fail (e) ->
            setImmediate ->
              iterate()

        else
          defer.resolve()

    iterate()

    defer.promise
