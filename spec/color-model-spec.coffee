Color = require '../lib/color-model'

require '../lib/color-expressions'
require '../lib/color-operations'

itShouldParseTheColor = (expr, red=0, green=0, blue=0, alpha=1) ->
  msg = "creates a color with red=#{red}, green=#{green}, blue=#{blue} and alpha=#{alpha}"
  desc = expr.replace(/#/g, '')

  describe "created with #{desc}", ->
    it msg, ->
      color = new Color(expr)

      expect(Math.round(color.red)).toEqual(red)
      expect(Math.round(color.green)).toEqual(green)
      expect(Math.round(color.blue)).toEqual(blue)
      expect(color.alpha).toBeCloseTo(alpha, 0.001)

itShouldntParseTheColor = (expr) ->
  describe "parsing the expression '#{expr}'", ->
    it 'cannot handle the expression', ->
      expect(Color.canHandle(expr)).toBeFalsy()

describe 'Color', ->

  itShouldParseTheColor('#ff7f00', 255, 127, 0)
  itShouldParseTheColor('#f70', 255, 119, 0)

  itShouldParseTheColor('0xff7f00', 255, 127, 0)
  itShouldParseTheColor('0x00ff7f00', 255, 127, 0, 0)

  itShouldParseTheColor('rgb(255,127,0)', 255, 127, 0)
  itShouldParseTheColor('rgba(255,127,0,0.5)', 255, 127, 0, 0.5)
  itShouldParseTheColor('rgba(255,127,0,.5)', 255, 127, 0, 0.5)

  itShouldntParseTheColor('rgba(255,127,0,)')

  itShouldParseTheColor('hsl(200,50%,50%)', 64, 149, 191)
  itShouldParseTheColor('hsla(200,50%,50%,0.5)', 64, 149, 191, 0.5)
  itShouldParseTheColor('hsla(200,50%,50%,.5)', 64, 149, 191, 0.5)

  itShouldntParseTheColor('hsla(200,50%,50%,)')

  itShouldParseTheColor('hsv(200,50%,50%)', 64, 106, 128)
  itShouldParseTheColor('hsva(200,50%,50%,0.5)', 64, 106, 128, 0.5)
  itShouldParseTheColor('hsva(200,50%,50%,.5)', 64, 106, 128, 0.5)

  itShouldntParseTheColor('hsva(200,50%,50%,)')

  itShouldParseTheColor('hwb(210,40%,40%)', 102, 128, 153)
  itShouldParseTheColor('hwb(210,40%,40%, 0.5)', 102, 128, 153, 0.5)

  itShouldParseTheColor('gray(100%)', 255, 255, 255)
  itShouldParseTheColor('gray(100%, 0.5)', 255, 255, 255, 0.5)

  itShouldParseTheColor('cyan', 0, 255, 255)

  itShouldParseTheColor('darken(cyan, 20%)', 0, 204, 204)
  itShouldParseTheColor('lighten(cyan, 20%)', 51, 255, 255)

  itShouldParseTheColor('transparentize(cyan, 50%)', 0, 255, 255, 0.5)
  itShouldParseTheColor('transparentize(cyan, 0.5)', 0, 255, 255, 0.5)
  itShouldParseTheColor('transparentize(cyan, .5)', 0, 255, 255, 0.5)
  itShouldParseTheColor('fadein(cyan, 0.5)', 0, 255, 255, 0.5)
  itShouldParseTheColor('fadein(cyan, .5)', 0, 255, 255, 0.5)

  itShouldParseTheColor('opacify(0x7800FFFF, 50%)', 0, 255, 255, 1)
  itShouldParseTheColor('opacify(0x7800FFFF, 0.5)', 0, 255, 255, 1)
  itShouldParseTheColor('opacify(0x7800FFFF, .5)', 0, 255, 255, 1)
  itShouldParseTheColor('fadeout(0x7800FFFF, 0.5)', 0, 255, 255, 1)
  itShouldParseTheColor('fadeout(0x7800FFFF, .5)', 0, 255, 255, 1)

  itShouldParseTheColor('saturate(#855, 20%)', 158, 63, 63)
  itShouldParseTheColor('saturate(#855, 0.2)', 158, 63, 63)

  itShouldParseTheColor('desaturate(#9e3f3f, 20%)', 136, 85, 85)
  itShouldParseTheColor('desaturate(#9e3f3f, 0.2)', 136, 85, 85)
  itShouldParseTheColor('desaturate(#9e3f3f, .2)', 136, 85, 85)

  itShouldParseTheColor('grayscale(#9e3f3f)', 111, 111, 111)
  itShouldParseTheColor('greyscale(#9e3f3f)', 111, 111, 111)

  itShouldParseTheColor('invert(#9e3f3f)', 97, 192, 192)

  itShouldParseTheColor('adjust-hue(#811, 45deg)', 136, 106, 17)
  itShouldParseTheColor('adjust-hue(#811, -45deg)', 136, 17, 106)

  itShouldParseTheColor('mix(#f00, #00f)', 127, 0, 127)
  itShouldParseTheColor('mix(#f00, #00f, 25%)', 63, 0, 191)

  itShouldParseTheColor('tint(#fd0cc7,66%)', 254, 172, 235)
  itShouldParseTheColor('color(#fd0cc7 tint(66%))', 254, 172, 236)

  itShouldParseTheColor('adjust-color(#102030, $red: -5, $blue: 5)', 11, 32, 53)
  itShouldParseTheColor('adjust-color(hsl(25, 100%, 80%), $lightness: -30%, $alpha: -0.4)', 255, 106, 0, 0.6)

  itShouldParseTheColor('scale-color(rgb(200, 150, 170), $green: -40%, $blue: 70%)', 200, 90, 230)

  itShouldParseTheColor('shade(#fd0cc7,66%)', 86, 4, 67)
