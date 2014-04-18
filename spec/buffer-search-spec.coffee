TextBuffer = require 'text-buffer'

Color = require '../lib/color-model'

require '../lib/color-expressions'
require '../lib/color-operations'

describe 'Color buffer search', ->
  beforeEach ->
    @buffer = new TextBuffer text: """
      color1 = #fff

      color2 = rgba(0,0,0,1)

      color3 = transparentize(red, 0.5)
    """
