{OnigRegExp} = require 'oniguruma'

Color = require '../lib/color-model'

{
  int
  float
  percent
  intOrPercent
  floatOrPercent
  comma
  notQuote
  hexa
  ps
  pe
} = require '../lib/regexes'

baseColor = null

Color.addExpression 'dummy', "\\bfoo\\(#{notQuote}#{comma}#{floatOrPercent}\\)", (color, expr) =>
  baseColor = expr

describe 'Color', ->
  beforeEach ->
    baseColor = undefined

  describe 'searchExpression', ->
    describe 'with a valid operation in the string', ->
      it 'calls back with a result', ->
        searchCallback = jasmine.createSpy('searchCallback')
        Color.searchExpression 'bar, foo(#fff, 20%)', 0, searchCallback

        waitsFor ->
          searchCallback.callCount is 1

        runs ->
          result = searchCallback.argsForCall[0][0]
          expect(result).toBeDefined()

    describe 'with no matches in the string', ->
      it 'calls back with null', ->
        searchCallback = jasmine.createSpy('searchCallback')
        Color.searchExpression 'bar', 0, searchCallback

        waitsFor ->
          searchCallback.callCount is 1

        runs ->
          result = searchCallback.argsForCall[0][0]
          expect(result).toBeUndefined()

    describe 'with a string looking like a color but is not', ->
      it 'calls back with null', ->
        searchCallback = jasmine.createSpy('searchCallback')
        Color.searchExpression '#addUser, #faddedUser', 0, searchCallback

        waitsFor ->
          searchCallback.callCount is 1

        runs ->
          result = searchCallback.argsForCall[0][0]
          expect(result).toBeUndefined()

    describe 'the returned promise', ->
      it 'yields the result', ->
        promise = Color.searchExpression 'bar, foo(#fff, 20%)', 0

        waitsFor -> not promise.isPending()

        runs ->
          promise.then (value) ->
            expect(value).toBeDefined()
    describe 'with a valid expression', ->
      it 'calls back with a result', ->
        searchCallback = jasmine.createSpy('searchCallback')
        Color.searchExpression 'bar, #fff, 20%', 0, searchCallback

        waitsFor ->
          searchCallback.callCount is 1

        runs ->
          result = searchCallback.argsForCall[0][0]
          expect(result).toBeDefined()

    describe 'with no matches in the string', ->
      it 'calls back with null', ->
        searchCallback = jasmine.createSpy('searchCallback')
        Color.searchExpression 'bar', 0, searchCallback

        waitsFor ->
          searchCallback.callCount is 1

        runs ->
          result = searchCallback.argsForCall[0][0]
          expect(result).toBeUndefined()

    describe 'the returned promise', ->
      it 'yields the result', ->
        promise = Color.searchExpression 'bar, foo(#fff, 20%)', 0

        waitsFor -> not promise.isPending()

        runs ->
          promise.then (value) ->
            expect(value).toBeDefined()

  describe 'searchColor', ->
    describe 'with a color in an operation', ->
      it 'yields the operation and not the color', ->
        promise = Color.searchColor 'bar, foo(#fff, 20%)', 0

        waitsFor -> not promise.isPending()

        runs ->
          promise.then (value) ->
            expect(value).toBeDefined()
            expect(value.match).toBe('foo(#fff, 20%)')

    describe 'with only a color', ->
      it 'yields the the color', ->
        promise = Color.searchColor 'bar, #fff, 20%', 0

        waitsFor -> not promise.isPending()

        runs ->
          promise.then (value) ->
            expect(value).toBeDefined()
            expect(value.match).toBe('#fff')

    describe 'with a color before an operation', ->
      it 'returns the color', ->
        promise = Color.searchColor 'bar, rgba(0,0,0,1), foo(red, 20%)', 3

        waitsFor -> not promise.isPending()

        runs ->
          promise.then (value) ->
            expect(value).toBeDefined()
            expect(value.match).toBe('#fff')


  describe '.searchExpressionSync', ->
    describe 'with a valid operation in the string', ->
      describe 'the results', ->
        it 'exists', ->
          result = Color.searchExpressionSync 'bar, foo(#fff, 20%)'
          expect(result).toBeDefined()

          expect(result.range).toBeDefined()
          expect(result.range).toEqual([5, 19])

          expect(result.match).toBeDefined()
          expect(result.match).toEqual('foo(#fff, 20%)')

    xdescribe 'with nested operations', ->

      describe 'the results', ->
        it 'exists', ->
          result = Color.searchExpressionSync 'foo, foo(foo(#fff, 20%), 50%)'
          expect(result).toBeDefined()

          expect(result.range).toBeDefined()
          expect(result.range).toEqual([5, 29])

          expect(result.match).toBeDefined()
          expect(result.match).toEqual('foo(foo(#fff, 20%), 50%)')

          expect(result.argMatches).toBeDefined()
          expect(result.argMatches.length).toEqual(2)

    describe 'with something that is not an expression', ->
      describe 'the results', ->
        it 'is undefined', ->
          result = Color.searchExpressionSync 'foo'
          expect(result).toBeUndefined()

    xdescribe 'with an incomplete expression before a complete one', ->
      describe 'the results', ->
        it 'exists', ->
          result = Color.searchExpressionSync 'foo(, bar, foo(#fff, 20%)'
          expect(result).toBeDefined()

          expect(result.range).toBeDefined()
          expect(result.range).toEqual([11, 25])

          expect(result.match).toBeDefined()
          expect(result.match).toEqual('foo(#fff, 20%)')

          expect(result.argMatches).toBeDefined()
          expect(result.argMatches.length).toEqual(2)

  describe 'during the creation of a color', ->
    describe 'created with foo(#fff, 20%)', ->
      beforeEach ->
        @color = new Color('foo(#fff, 20%)')

      it 'calls the handler', ->
        expect(baseColor).toBeDefined()
        expect(baseColor).toEqual('foo(#fff, 20%)')

    describe 'created with foo(10)', ->
      beforeEach ->
        @color = new Color('foo(10)')

      it 'does not call the handler', ->
        expect(baseColor).toBeUndefined()
