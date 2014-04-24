fs = require 'fs'
path = require 'path'
TextBuffer = require 'text-buffer'

Color = require '../lib/color-model'

require '../lib/color-operations'
require '../lib/color-expressions'

describe 'Color', ->
  beforeEach ->
    @buffer = new TextBuffer text: """
      color1 = #fff

      color2 = rgba(0,0,0,1)

      color3 = transparentize(red, 0.5)

      color4 = #000
    """

  describe '.scanBufferForColorsInRange', ->
    describe 'for a restricted range', ->
      describe 'the passed-in callback', ->
        it 'should have been called only once', ->
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
              expect(results[0].bufferRange.start.row).toEqual(2)
              expect(results[0].bufferRange.start.column).toEqual(9)
              expect(results[0].bufferRange.end.row).toEqual(2)
              expect(results[0].bufferRange.end.column).toEqual(22)

    describe 'for a wider range', ->
      describe 'the passed-in callback', ->
        it 'should have been called thrice', ->
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
                '#000'
              ])

    describe 'for a full range', ->
      describe 'the passed-in callback', ->
        it 'should have been called four times', ->
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
                '#000'
              ])

  describe '.scanBufferForColors', ->
    describe 'the passed-in callback', ->
      it 'should have been called four times', ->
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
              '#000'
            ])

  describe 'with a big buffer', ->
    beforeEach ->
      @buffer = new TextBuffer text: fs.readFileSync(path.resolve __dirname, './fixtures/real_world_example.coffee').toString()

    it 'should have been called four times', ->
      searchCallback = jasmine.createSpy('searchCallback')
      promise = Color.scanBufferForColors(@buffer, searchCallback)

      waitsFor -> not promise.isPending()

      runs ->
        expect(true).toEqual(true)
