TextBuffer = require 'text-buffer'

Color = require '../lib/color-model'

require '../lib/color-expressions'
require '../lib/color-operations'

describe 'Color', ->
  beforeEach ->
    @buffer = new TextBuffer text: """
      color1 = #fff

      color2 = rgba(0,0,0,1)

      color3 = transparentize(red, 0.5)
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

    describe 'for a wider range', ->
      describe 'the passed-in callback', ->
        it 'should have been called twice', ->
          searchCallback = jasmine.createSpy('searchCallback')
          promise = Color.scanBufferForColorsInRange(@buffer, [[2,0],[Infinity, Infinity]], searchCallback)

          waitsFor -> not promise.isPending()
          runs ->
            expect(searchCallback.callCount).toEqual(2)
            promise.then (results) ->
              res = results.map (m) -> m.match
              expect(res).toEqual([
                'rgba(0,0,0,1)'
                'transparentize(red, 0.5)'
              ])

    describe 'for a full range', ->
      describe 'the passed-in callback', ->
        it 'should have been called twice', ->
          searchCallback = jasmine.createSpy('searchCallback')
          promise = Color.scanBufferForColorsInRange(@buffer, [[0,0],[Infinity, Infinity]], searchCallback)

          waitsFor -> not promise.isPending()
          runs ->
            expect(searchCallback.callCount).toEqual(3)
            promise.then (results) ->
              res = results.map (m) -> m.match
              expect(res).toEqual([
                '#fff'
                'rgba(0,0,0,1)'
                'transparentize(red, 0.5)'
              ])
