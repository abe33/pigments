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

describe 'Color', ->
  beforeEach ->
    Color.colorOperations = []
    Color.addOperation 'foo\\(', Color, floatOrPercent, '\\)', (color, [@baseColor, @amount]) =>

  describe '.searchOperation', ->
    describe 'with a valid operation in the string', ->
      beforeEach ->
        @result = Color.searchOperation 'bar, foo(#fff, 20%)'

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
        @result = Color.searchOperation 'foo, foo(foo(#fff, 20%), 50%)'

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
        @result = Color.searchOperation

  describe 'with an operation defined', ->
    describe 'created with foo(#fff, 20%)', ->
      beforeEach ->
        @color = new Color('foo(#fff, 20%)')

      it 'should have called the handler', ->
        expect(@baseColor).toBeDefined()
        expect(@amount).toBeDefined()

        expect(@baseColor).toEqual(new Color('#fff'))
        expect(@amount).toEqual('20%')

    describe 'created with foo(10)', ->
      beforeEach ->
        @color = new Color('foo(10)')

      it 'should not call the handler', ->
        expect(@baseColor).toBeUndefined()
        expect(@amount).toBeUndefined()
