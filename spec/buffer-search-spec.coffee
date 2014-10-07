fs = require 'fs'
path = require 'path'
TextBuffer = require 'text-buffer'

Color = require '../lib/color-model'

require '../lib/color-operations'
require '../lib/color-expressions'
require '../lib/color-variables'

describe 'Color', ->
  beforeEach ->
    @buffer = new TextBuffer text: """
      color1 = #fff

      color2 = rgba(0,0,0,1)

      color3 = transparentize(red, 0.5)

      other-color = transparentize(color1, 50%)
    """

  describe '.scanBufferForColorsInRange', ->
    describe 'for a restricted range', ->
      it 'calls the callback only once', (done) ->
        searchCallback = jasmine.createSpy('searchCallback')
        promise = Color.scanBufferForColorsInRange(@buffer, [[2,0],[4,0]], searchCallback)

        waitsFor -> not promise.isPending()
        runs ->
          expect(searchCallback.callCount).toEqual(1)
          promise.then (results) ->
            res = results.map (m) -> m.match
            expect(res).toEqual([
              'rgba(0,0,0,1)'
            ])

            expect(results[0].bufferRange).toBeDefined()
            expect(results[0].color).toBeDefined()
            expect(results[0].color.red).toEqual(0)
            expect(results[0].color.green).toEqual(0)
            expect(results[0].color.blue).toEqual(0)
            expect(results[0].color.alpha).toEqual(1)
            expect(results[0].bufferRange.start.row).toEqual(2)
            expect(results[0].bufferRange.start.column).toEqual(9)
            expect(results[0].bufferRange.end.row).toEqual(2)
            expect(results[0].bufferRange.end.column).toEqual(22)

            done()

    describe 'for a wider range', ->
      it 'calls the callback thrice', (done) ->
        searchCallback = jasmine.createSpy('searchCallback')
        promise = Color.scanBufferForColorsInRange(@buffer, [[2,0],[Infinity, Infinity]], searchCallback)

        waitsFor -> not promise.isPending()
        runs ->
          expect(searchCallback.callCount).toEqual(3)
          promise.then (results) ->
            res = results.map (m) -> m.match
            expect(res).toEqual([
              'rgba(0,0,0,1)'
              'transparentize(red, 0.5)'
              'transparentize(color1, 50%)'
            ])
            done()

    describe 'for a full range', ->
      it 'calls the callback four times', (done) ->
        searchCallback = jasmine.createSpy('searchCallback')
        promise = Color.scanBufferForColorsInRange(@buffer, [[0,0],[Infinity, Infinity]], searchCallback)

        waitsFor -> not promise.isPending()
        runs ->
          expect(searchCallback.callCount).toEqual(4)
          promise.then (results) ->
            res = results.map (m) -> m.match
            expect(res).toEqual([
              '#fff'
              'rgba(0,0,0,1)'
              'transparentize(red, 0.5)'
              'transparentize(color1, 50%)'
            ])
            done()

      it 'creates a color with the declaration in the range', (done) ->
        searchCallback = jasmine.createSpy('searchCallback')
        promise = Color.scanBufferForColorsInRange(@buffer, [[0,0],[Infinity, Infinity]], searchCallback)

        waitsFor -> not promise.isPending()
        runs ->
          promise.then (results) ->
            color = results[3].color

            expect(color.red).toEqual(255)
            expect(color.green).toEqual(255)
            expect(color.blue).toEqual(255)
            expect(color.alpha).toEqual(0.5)
            done()

  describe '.scanBufferForColors', ->
    it 'calls the callback four times', (done) ->
      searchCallback = jasmine.createSpy('searchCallback')
      promise = Color.scanBufferForColors(@buffer, searchCallback)

      waitsFor -> not promise.isPending()
      runs ->
        expect(searchCallback.callCount).toEqual(4)
        promise.then (results) ->
          res = results.map (m) -> m.match
          expect(res).toEqual([
            '#fff'
            'rgba(0,0,0,1)'
            'transparentize(red, 0.5)'
            'transparentize(color1, 50%)'
          ])
          done()

    describe 'with a big buffer', ->
      beforeEach ->
        @buffer = new TextBuffer text: fs.readFileSync(path.resolve __dirname, './fixtures/real_world_example.coffee').toString()

      it 'calls the callback four times', (done) ->
        searchCallback = jasmine.createSpy('searchCallback')
        promise = Color.scanBufferForColors(@buffer, searchCallback)

        expect(true).toEqual(true)
        done()

    describe 'with a variables hash', ->
      it 'creates the colors using the passed-in variables', (done) ->
        searchCallback = jasmine.createSpy('searchCallback')
        variables =
          color1:
            value: 'red'
            isColor: true

        promise = Color.scanBufferForColors(@buffer, variables, searchCallback)

        promise.then (results) ->
          last = results[results.length - 1]

          expect(last.color.red).toEqual(255)
          expect(last.color.green).toEqual(0)
          expect(last.color.blue).toEqual(0)
          expect(last.color.alpha).toEqual(0.5)

          done()

  describe '.scanBufferForVariables', ->
    describe 'with a buffer containing less variables', ->
      beforeEach ->
        @buffer = new TextBuffer {
          text: """
          @red: #f00

          @light-red_var: lighten(@red, 10%);

          @not_a_color: 10px;
          """
          filePath: 'some_path.less'
        }

      it 'calls the callback three times', (done) ->
        searchCallback = jasmine.createSpy('searchCallback')
        promise = Color.scanBufferForVariables(@buffer, searchCallback)

        expect(searchCallback.callCount).toEqual(3)
        promise.then (results) ->
          expect(results).toEqual({
            '@red':
              value: '#f00'
              range: [[0,0], [0,10]]
              isColor: true
            '@light-red_var':
              value: 'lighten(@red, 10%)'
              range: [[2,0], [2,35]]
              isColor: true
            '@not_a_color':
              value: '10px'
              range: [[4,0],[4,19]]
              isColor: false
          })
          done()

    describe 'with a buffer containing sass variables', ->
      beforeEach ->
        @buffer = new TextBuffer {
          text: """
          $red: #f00

          $light-red_var: lighten($red, 10%)

          $not_a_color: 10px
          """
          filePath: 'some_path.sass'
        }
      it 'calls the callback two times', (done) ->
        searchCallback = jasmine.createSpy('searchCallback')
        promise = Color.scanBufferForVariables(@buffer, searchCallback)

        expect(searchCallback.callCount).toEqual(3)
        promise.then (results) ->
          expect(results).toEqual({
            '$red':
              value: '#f00'
              range: [[0,0], [0,10]]
              isColor: true
            '$light-red_var':
              value: 'lighten($red, 10%)'
              range: [[2,0], [2,34]]
              isColor: true
            '$not_a_color':
              value: '10px'
              range: [[4,0],[4,18]]
              isColor: false
          })
          done()

    describe 'with a buffer containing scss variables', ->
      beforeEach ->
        @buffer = new TextBuffer {
          text: """
          $red: #f00;

          $light-red_var: lighten($red, 10%);

          $not_a_color: 10px;
          """
          filePath: 'some_path.scss'
        }
      it 'calls the callback two times', (done) ->
        searchCallback = jasmine.createSpy('searchCallback')
        promise = Color.scanBufferForVariables(@buffer, searchCallback)

        expect(searchCallback.callCount).toEqual(3)
        promise.then (results) ->
          expect(results).toEqual({
            '$red':
              value: '#f00'
              range: [[0,0], [0,11]]
              isColor: true
            '$light-red_var':
              value: 'lighten($red, 10%)'
              range: [[2,0], [2,35]]
              isColor: true
            '$not_a_color':
              value: '10px'
              range: [[4,0],[4,19]]
              isColor: false
          })
          done()

    describe 'with a buffer containing stylus variables', ->
      beforeEach ->
        @buffer = new TextBuffer {
          text: """
          red = #f00

          light-red_var= lighten(red, 10%);

          not_a_color = 10px
          """
          filePath: 'some_path.styl'
        }
      it 'calls the callback two times', (done) ->
        searchCallback = jasmine.createSpy('searchCallback')
        promise = Color.scanBufferForVariables(@buffer, searchCallback)

        expect(searchCallback.callCount).toEqual(3)
        promise.then (results) ->
          expect(results).toEqual({
            'red':
              value: '#f00'
              range: [[0,0], [0,10]]
              isColor: true
            'light-red_var':
              value: 'lighten(red, 10%)'
              range: [[2,0], [2,33]]
              isColor: true
            'not_a_color':
              value: '10px'
              range: [[4,0],[4,18 ]]
              isColor: false
          })
          done()

  describe 'with a buffer where expressions relies on non-color variables', ->
    beforeEach ->
      @buffer = new TextBuffer text: """
        $factor: 40%

        $color: scale-color(#ff0000, $lightness: $factor)
        $other-color: saturate(#123456, $factor)
      """

    it 'uses the other variables from the file', (done) ->
      searchCallback = jasmine.createSpy('searchCallback')
      promise = Color.scanBufferForColors(@buffer, searchCallback)

      promise.then (results) ->
        expect(results.length).toEqual(2)

        expect(results[0].match).toEqual('scale-color(#ff0000, $lightness: $factor)')
        expect(results[0].color[0]).toBeCloseTo(255)
        expect(results[0].color[1]).toBeCloseTo(102)
        expect(results[0].color[2]).toBeCloseTo(102)
        expect(results[0].color[3]).toBeCloseTo(1)

        expect(results[1].match).toEqual('saturate(#123456, $factor)')
        expect(results[1].color[0]).toBeCloseTo(0)
        expect(results[1].color[1]).toBeCloseTo(52)
        expect(results[1].color[2]).toBeCloseTo(104)
        expect(results[1].color[3]).toBeCloseTo(1)

        done()

  describe 'with a variable containing a dash', ->
    beforeEach ->
      @buffer = new TextBuffer text: """
        $function-factor: -7%;

        $bg: scale-color(#fff, $lightness: $function-factor);

        $border-color: scale-color($bg, $lightness: $function-factor);
      """

    it 'uses the other variables from the file', (done) ->
      searchCallback = jasmine.createSpy('searchCallback')
      promise = Color.scanBufferForColors(@buffer, searchCallback)

      promise.then (results) ->

        expect(results.length).toEqual(2)

        expect(results[0].match).toEqual('scale-color(#fff, $lightness: $function-factor)')
        expect(results[1].match).toEqual('scale-color($bg, $lightness: $function-factor)')
        done()

  describe 'with a selector just after a color', ->
    beforeEach ->
      @buffer = new TextBuffer text: """
      $color_grey_lighter: #efefef

      .foo
        .bar
          border-left: 1px solid $color_grey_lighter
          border-right: 1px solid $color_grey_lighter

      .baz
        border-right: 1px solid $color_grey_lighter

      """

    it 'does not fail at finding the color preceding the selector', (done) ->
      searchCallback = jasmine.createSpy('searchCallback')
      promise = Color.scanBufferForColors(@buffer, searchCallback)

      promise.then (results) ->
        expect(results.length).toEqual(4)
        done()

  describe 'with a variable name containing a previous variable', ->
    beforeEach ->
      @buffer = new TextBuffer text: """
      $color: #efefef
      $color_blue: #efefef
      """

    it 'does not fail at ignoring matches', (done) ->
      searchCallback = jasmine.createSpy('searchCallback')
      promise = Color.scanBufferForColors(@buffer, searchCallback)

      promise.then (results) ->
        expect(results.length).toEqual(2)
        done()

  describe 'with more than one aliased color variables', ->
    beforeEach ->
      @buffer = new TextBuffer text: """
      @one: #fff;
      @two: @one;
      @three: @two;
      @four: @three;
      """

    it 'finds all the aliases as color variables', ->
      searchCallback = jasmine.createSpy('searchCallback')
      promise = Color.scanBufferForColors(@buffer, searchCallback)

      promise.then (results) ->
        expect(results.length).toEqual(4)
        done()

  describe 'with ambiguous definition', ->
    beforeEach ->
      @buffer = new TextBuffer text: fs.readFileSync(path.resolve __dirname, './fixtures/infinite_loop.coffee').toString()

    it 'does not find any color nor run into an infinite loop', ->
      searchCallback = jasmine.createSpy('searchCallback')
      promise = Color.scanBufferForColors(@buffer, searchCallback)

      promise.then (results) ->
        expect(results.length).toEqual(2)
        done()

  describe 'with variable names containing a named color', ->
    beforeEach ->
      @buffer = new TextBuffer text: """
      .cyan
      @blue
      $green,yellow

      border:cyan
      some_color=green
      background: darken(red, 20%)
      """

    it 'does not fail at ignoring matches', (done) ->
      searchCallback = jasmine.createSpy('searchCallback')
      promise = Color.scanBufferForColors(@buffer, searchCallback)

      promise.then (results) ->
        expect(results.length).toEqual(4)
        expect(results[0].range).toEqual([19,25])
        done()

  describe 'with various cases for colors', ->
    beforeEach ->
      @buffer = new TextBuffer text: """
      CYAN
      red
      YellowGreen

      color = blue

      Color
      """

    it 'ignores different variable case', (done) ->
      searchCallback = jasmine.createSpy('searchCallback')
      promise = Color.scanBufferForColors(@buffer, searchCallback)

      promise
      .then (results) ->
        expect(results.length).toEqual(4)
        done()
      .fail (reason) ->
        console.log reason.stack
        done()
