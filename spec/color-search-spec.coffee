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
amount = null

Color.addOperation '\\bfoo\\(', Color, floatOrPercent, '\\)', (color, [a, b]) =>
  baseColor = a
  amount = b

describe 'Color', ->
  beforeEach ->
    baseColor = undefined
    amount = undefined

  describe '.searchOperation', ->
    describe 'with a valid operation in the string', ->
      it 'should call back with a result', ->
        searchCallback = jasmine.createSpy('searchCallback')
        Color.searchOperation 'bar, foo(#fff, 20%)', 0, searchCallback

        waitsFor ->
          searchCallback.callCount is 1

        runs ->
          result = searchCallback.argsForCall[0][0]
          expect(result).toBeDefined()

    describe 'with no matches in the string', ->
      it 'should call back with null', ->
        searchCallback = jasmine.createSpy('searchCallback')
        Color.searchOperation 'bar', 0, searchCallback

        waitsFor ->
          searchCallback.callCount is 1

        runs ->
          result = searchCallback.argsForCall[0][0]
          expect(result).toBeUndefined()

    describe 'the returned promise', ->
      it 'should yield the result', ->
        promise = Color.searchOperation 'bar, foo(#fff, 20%)', 0

        waitsFor -> not promise.isPending()

        runs ->
          promise.then (value) ->
            expect(value).toBeDefined()

  describe 'searchExpression', ->
    describe 'with a valid expression', ->
      it 'should call back with a result', ->
        searchCallback = jasmine.createSpy('searchCallback')
        Color.searchExpression 'bar, #fff, 20%', 0, searchCallback

        waitsFor ->
          searchCallback.callCount is 1

        runs ->
          result = searchCallback.argsForCall[0][0]
          expect(result).toBeDefined()

    describe 'with no matches in the string', ->
      it 'should call back with null', ->
        searchCallback = jasmine.createSpy('searchCallback')
        Color.searchExpression 'bar', 0, searchCallback

        waitsFor ->
          searchCallback.callCount is 1

        runs ->
          result = searchCallback.argsForCall[0][0]
          expect(result).toBeUndefined()

    describe 'the returned promise', ->
      it 'should yield the result', ->
        promise = Color.searchExpression 'bar, foo(#fff, 20%)', 0

        waitsFor -> not promise.isPending()

        runs ->
          promise.then (value) ->
            expect(value).toBeDefined()

  describe 'searchColor', ->
    describe 'with a color in an operation', ->
      it 'should yield the operation and not the color', ->
        promise = Color.searchColor 'bar, foo(#fff, 20%)', 0

        waitsFor -> not promise.isPending()

        runs ->
          promise.then (value) ->
            expect(value).toBeDefined()
            expect(value.match).toBe('foo(#fff, 20%)')

    describe 'with only a color', ->
      it 'should yield the the color', ->
        promise = Color.searchColor 'bar, #fff, 20%', 0

        waitsFor -> not promise.isPending()

        runs ->
          promise.then (value) ->
            expect(value).toBeDefined()
            expect(value.match).toBe('#fff')

    describe 'with a color before an operation', ->
      it 'should return the color', ->
        promise = Color.searchColor 'bar, rgba(0,0,0,1), foo(red, 20%)', 3

        waitsFor -> not promise.isPending()

        runs ->
          promise.then (value) ->
            expect(value).toBeDefined()
            expect(value.match).toBe('#fff')


  describe '.searchOperationSync', ->
    describe 'with a valid operation in the string', ->
      beforeEach ->
        @result = Color.searchOperationSync 'bar, foo(#fff, 20%)'

      describe 'the results', ->
        it 'should exist', ->
          expect(@result).toBeDefined()

        it 'should have a range', ->
          expect(@result.range).toBeDefined()
          expect(@result.range).toEqual([5, 19])

        it 'should have a match', ->
          expect(@result.match).toBeDefined()
          expect(@result.match).toEqual('foo(#fff, 20%)')

    describe 'with nested operations', ->
      beforeEach ->
        @result = Color.searchOperationSync 'foo, foo(foo(#fff, 20%), 50%)'

      describe 'the results', ->
        it 'should exist', ->
          expect(@result).toBeDefined()

        it 'should have a range', ->
          expect(@result.range).toBeDefined()
          expect(@result.range).toEqual([5, 29])

        it 'should have a match', ->
          expect(@result.match).toBeDefined()
          expect(@result.match).toEqual('foo(foo(#fff, 20%), 50%)')

        it 'should have an argMatches array', ->
          expect(@result.argMatches).toBeDefined()
          expect(@result.argMatches.length).toEqual(2)

    describe 'with something that is not an expression', ->
      beforeEach ->
        @result = Color.searchOperationSync 'foo'

      describe 'the results', ->
        it 'should be undefined', ->
          expect(@result).toBeUndefined()

    describe 'with an incomplete expression before a complete one', ->
      beforeEach ->
        @result = Color.searchOperationSync 'foo(, bar, foo(#fff, 20%)'

      describe 'the results', ->
        it 'should exist', ->
          expect(@result).toBeDefined()

        it 'should have a range', ->
          expect(@result.range).toBeDefined()
          expect(@result.range).toEqual([11, 25])

        it 'should have a match', ->
          expect(@result.match).toBeDefined()
          expect(@result.match).toEqual('foo(#fff, 20%)')

        it 'should have an argMatches array', ->
          expect(@result.argMatches).toBeDefined()
          expect(@result.argMatches.length).toEqual(2)

  describe 'during the creation of a color', ->
    describe 'created with foo(#fff, 20%)', ->
      beforeEach ->
        @color = new Color('foo(#fff, 20%)')

      it 'should have called the handler', ->
        expect(baseColor).toBeDefined()
        expect(amount).toBeDefined()

        expect(baseColor).toEqual(new Color('#fff'))
        expect(amount).toEqual('20%')

    describe 'created with foo(10)', ->
      beforeEach ->
        @color = new Color('foo(10)')

      it 'should not call the handler', ->
        expect(baseColor).toBeUndefined()
        expect(amount).toBeUndefined()
