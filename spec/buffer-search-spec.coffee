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

      color4 = transparentize(color1, 50%)
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

      it 'creates a color with the declarationin the range', (done) ->
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

      it 'calls the callback four times', ->
        searchCallback = jasmine.createSpy('searchCallback')
        promise = Color.scanBufferForColors(@buffer, searchCallback)

        waitsFor -> not promise.isPending()

        runs ->
          expect(true).toEqual(true)

  describe '.scanBufferForColorVariables', ->
    describe 'with a buffer containing less variables', ->
      beforeEach ->
        @buffer = new TextBuffer {
          text: """
          @red: #f00;

          @light_red: lighten(@red, 10%);

          @not_a_color: 10px;
          """
          filePath: 'some_path.less'
        }

      it 'calls the callback two times', (done) ->
        searchCallback = jasmine.createSpy('searchCallback')
        promise = Color.scanBufferForColorVariables(@buffer, searchCallback)

        waitsFor -> not promise.isPending()

        runs ->
          expect(searchCallback.callCount).toEqual(2)
          promise.then (results) ->
            expect(results).toEqual({
              '@red': '#f00'
              '@light_red': 'lighten(@red, 10%)'
            })
            done()

    describe 'with a buffer containing sass variables', ->
      beforeEach ->
        @buffer = new TextBuffer {
          text: """
          $red: #f00

          $light_red: lighten($red, 10%)

          $not_a_color: 10px
          """
          filePath: 'some_path.sass'
        }
      it 'calls the callback two times', (done) ->
        searchCallback = jasmine.createSpy('searchCallback')
        promise = Color.scanBufferForColorVariables(@buffer, searchCallback)

        waitsFor -> not promise.isPending()

        runs ->
          expect(searchCallback.callCount).toEqual(2)
          promise.then (results) ->
            expect(results).toEqual({
              '$red': '#f00'
              '$light_red': 'lighten($red, 10%)'
            })
            done()

    describe 'with a buffer containing scss variables', ->
      beforeEach ->
        @buffer = new TextBuffer {
          text: """
          $red: #f00;

          $light_red: lighten($red, 10%);

          $not_a_color: 10px;
          """
          filePath: 'some_path.scss'
        }
      it 'calls the callback two times', (done) ->
        searchCallback = jasmine.createSpy('searchCallback')
        promise = Color.scanBufferForColorVariables(@buffer, searchCallback)

        waitsFor -> not promise.isPending()

        runs ->
          expect(searchCallback.callCount).toEqual(2)
          promise.then (results) ->
            expect(results).toEqual({
              '$red': '#f00'
              '$light_red': 'lighten($red, 10%)'
            })
            done()

    describe 'with a buffer containing scss variables', ->
      beforeEach ->
        @buffer = new TextBuffer {
          text: """
          red = #f00

          light_red= lighten(red, 10%);

          not_a_color = 10px
          """
          filePath: 'some_path.styl'
        }
      it 'calls the callback two times', (done) ->
        searchCallback = jasmine.createSpy('searchCallback')
        promise = Color.scanBufferForColorVariables(@buffer, searchCallback)

        waitsFor -> not promise.isPending()

        runs ->
          expect(searchCallback.callCount).toEqual(2)
          promise.then (results) ->
            expect(results).toEqual({
              'red': '#f00'
              'light_red': 'lighten(red, 10%)'
            })
            done()
