Color = require '../lib/color-model'
util = require 'util'

require '../lib/color-expressions'
require '../lib/color-operations'

itShouldParseTheColor = (expr, red=0, green=0, blue=0, alpha=1) ->
  msg = "creates a color with red=#{red}, green=#{green}, blue=#{blue} and alpha=#{alpha}"
  desc = expr.replace(/#/g, '')

  describe "created with #{desc}", ->
    it msg, ->
      color = new Color(expr)

      expect(color.isInvalid).toBeFalsy()
      expect(Math.round(color.red)).toEqual(red)
      expect(Math.round(color.green)).toEqual(green)
      expect(Math.round(color.blue)).toEqual(blue)
      expect(color.alpha).toBeCloseTo(alpha, 0.001)

itShouldParseTheColorWithVariables = (expr, vars, red=0, green=0, blue=0, alpha=1) ->
  msg = "creates a color with red=#{red}, green=#{green}, blue=#{blue} and alpha=#{alpha}"
  desc = expr.replace(/#/g, '')

  describe "created with #{desc} and variables #{util.inspect(vars)}", ->
    it msg, ->
      color = new Color(expr, vars)

      expect(color.isInvalid).toBeFalsy()
      expect(Math.round(color.red)).toEqual(red)
      expect(Math.round(color.green)).toEqual(green)
      expect(Math.round(color.blue)).toEqual(blue)
      expect(color.alpha).toBeCloseTo(alpha, 0.001)

itShouldParseTheColorAsInvalid = (expr, vars={}) ->
  msg = "creates an invalid color"
  desc = expr.replace(/#/g, '')

  describe "created with #{desc}", ->
    it msg, ->
      color = new Color(expr, vars)

      expect(color.isInvalid).toBeTruthy()

itShouldntParseTheColor = (expr) ->
  describe "parsing the expression '#{expr}'", ->
    it 'cannot handle the expression', ->
      expect(Color.canHandle(expr)).toBeFalsy()

describe 'Color', ->

  itShouldParseTheColor('#7fff7f00', 255, 127, 0, 0.5)
  itShouldParseTheColor('#ff7f00', 255, 127, 0)
  itShouldParseTheColor('#f70', 255, 119, 0)

  itShouldParseTheColor('0xff7f00', 255, 127, 0)
  itShouldParseTheColor('0x00ff7f00', 255, 127, 0, 0)

  itShouldParseTheColor('rgb(255,127,0)', 255, 127, 0)
  itShouldParseTheColor('rgba(255,127,0,0.5)', 255, 127, 0, 0.5)
  itShouldParseTheColor('rgba(255,127,0,.5)', 255, 127, 0, 0.5)
  itShouldntParseTheColor('rgba(255,127,0,)')
  itShouldParseTheColorAsInvalid('rgb($r,$g,$b)')
  itShouldParseTheColorWithVariables('rgb($r,$g,$b)', {
    '$r':
      value: '255'
    '$g':
      value: '127'
    '$b':
      value: '0'
  }, 255, 127, 0)
  itShouldParseTheColorAsInvalid('rgba($r,$g,$b,$a)')
  itShouldParseTheColorWithVariables('rgba($r,$g,$b,$a)', {
    '$r':
      value: '255'
    '$g':
      value: '127'
    '$b':
      value: '0'
    '$a':
      value: '0.5'
  }, 255, 127, 0, 0.5)

  itShouldParseTheColor('rgba(green, 0.5)', 0, 128, 0, 0.5)
  itShouldParseTheColorAsInvalid('rgba($c,$a)')
  itShouldParseTheColorWithVariables('rgba($c,$a)', {
    '$c':
      value: 'green'
    '$a':
      value: '0.5'
  }, 0, 128, 0, 0.5)

  itShouldParseTheColor('hsl(200,50%,50%)', 64, 149, 191)
  itShouldParseTheColor('hsla(200,50%,50%,0.5)', 64, 149, 191, 0.5)
  itShouldParseTheColor('hsla(200,50%,50%,.5)', 64, 149, 191, 0.5)
  itShouldParseTheColorAsInvalid('hsl($h,$s,$l)')
  itShouldParseTheColorWithVariables('hsl($h,$s,$l)', {
    '$h':
      value: '200'
    '$s':
      value: '50%'
    '$l':
      value: '50%'
  }, 64, 149, 191)
  itShouldParseTheColorAsInvalid('hsla($h,$s,$l,$a)')
  itShouldParseTheColorWithVariables('hsla($h,$s,$l,$a)', {
    '$h':
      value: '200'
    '$s':
      value: '50%'
    '$l':
      value: '50%'
    '$a':
      value: '0.5'
  }, 64, 149, 191, 0.5)

  itShouldntParseTheColor('hsla(200,50%,50%,)')

  itShouldParseTheColor('hsv(200,50%,50%)', 64, 106, 128)
  itShouldParseTheColor('hsva(200,50%,50%,0.5)', 64, 106, 128, 0.5)
  itShouldParseTheColor('hsva(200,50%,50%,.5)', 64, 106, 128, 0.5)
  itShouldParseTheColorAsInvalid('hsv($h,$s,$v)')
  itShouldParseTheColorWithVariables('hsv($h,$s,$v)',{
    '$h':
      value: '200'
    '$s':
      value: '50%'
    '$v':
      value: '50%'
  }, 64, 106, 128)
  itShouldParseTheColorAsInvalid('hsva($h,$s,$v,$a)')
  itShouldParseTheColorWithVariables('hsva($h,$s,$v,$a)',{
    '$h':
      value: '200'
    '$s':
      value: '50%'
    '$v':
      value: '50%'
    '$a':
      value: '0.5'
  }, 64, 106, 128, 0.5)

  itShouldntParseTheColor('hsva(200,50%,50%,)')

  itShouldParseTheColor('hwb(210,40%,40%)', 102, 128, 153)
  itShouldParseTheColor('hwb(210,40%,40%, 0.5)', 102, 128, 153, 0.5)
  itShouldParseTheColorAsInvalid('hwb($h,$w,$b)')
  itShouldParseTheColorAsInvalid('hwb($h,$w,$b,$a)')
  itShouldParseTheColorWithVariables('hwb($h,$w,$b)', {
    '$h':
      value: '210'
    '$w':
      value: '40%'
    '$b':
      value: '40%'
  }, 102, 128, 153)
  itShouldParseTheColorWithVariables('hwb($h,$w,$b,$a)', {
    '$h':
      value: '210'
    '$w':
      value: '40%'
    '$b':
      value: '40%'
    '$a':
      value: '0.5'
  }, 102, 128, 153, 0.5)

  itShouldParseTheColor('gray(100%)', 255, 255, 255)
  itShouldParseTheColor('gray(100%, 0.5)', 255, 255, 255, 0.5)
  itShouldParseTheColorAsInvalid('gray($c, $a)')
  itShouldParseTheColorWithVariables('gray($c, $a)', {
    '$c':
      value: '100%'
    '$a':
      value: '0.5'
  }, 255, 255, 255, 0.5)

  itShouldParseTheColor('cyan', 0, 255, 255)

  itShouldParseTheColor('darken(cyan, 20%)', 0, 153, 153)
  itShouldParseTheColor('darken(#fff, 100%)', 0, 0, 0)
  itShouldParseTheColorAsInvalid('darken(cyan, $r)')
  itShouldParseTheColorWithVariables('darken($c, $r)', {
    '$c':
      value: 'cyan'
    '$r':
      value: '20%'
  }, 0, 153, 153)
  itShouldParseTheColorWithVariables('darken($a, $r)', {
    '$a':
      value: 'rgba($c, 1)'
    '$c':
      value: 'cyan'
    '$r':
      value: '20%'
  }, 0, 153, 153)

  itShouldParseTheColor('lighten(cyan, 20%)', 102, 255, 255)
  itShouldParseTheColor('lighten(#000, 100%)', 255, 255, 255)
  itShouldParseTheColorAsInvalid('lighten(cyan, $r)')
  itShouldParseTheColorWithVariables('lighten($c, $r)', {
    '$c':
      value: 'cyan'
    '$r':
      value: '20%'
  }, 102, 255, 255)
  itShouldParseTheColorWithVariables('lighten($a, $r)', {
    '$a':
      value: 'rgba($c, 1)'
    '$c':
      value: 'cyan'
    '$r':
      value: '20%'
  }, 102, 255, 255)

  itShouldParseTheColor('transparentize(cyan, 50%)', 0, 255, 255, 0.5)
  itShouldParseTheColor('transparentize(cyan, 0.5)', 0, 255, 255, 0.5)
  itShouldParseTheColor('transparentize(cyan, .5)', 0, 255, 255, 0.5)
  itShouldParseTheColor('fadein(cyan, 0.5)', 0, 255, 255, 0.5)
  itShouldParseTheColor('fadein(cyan, .5)', 0, 255, 255, 0.5)
  itShouldParseTheColorAsInvalid('fadein(cyan, @r)')
  itShouldParseTheColorWithVariables('fadein(@c, @r)', {
    '@c':
      value: 'cyan'
    '@r':
      value: '0.5'
  }, 0, 255, 255, 0.5)
  itShouldParseTheColorWithVariables('fadein(@a, @r)', {
    '@a':
      value: 'rgba(@c, 1)'
    '@c':
      value: 'cyan'
    '@r':
      value: '0.5'
  }, 0, 255, 255, 0.5)


  itShouldParseTheColor('opacify(0x7800FFFF, 50%)', 0, 255, 255, 1)
  itShouldParseTheColor('opacify(0x7800FFFF, 0.5)', 0, 255, 255, 1)
  itShouldParseTheColor('opacify(0x7800FFFF, .5)', 0, 255, 255, 1)
  itShouldParseTheColor('fadeout(0x7800FFFF, 0.5)', 0, 255, 255, 1)
  itShouldParseTheColor('fadeout(0x7800FFFF, .5)', 0, 255, 255, 1)
  itShouldParseTheColorAsInvalid('fadeout(0x7800FFFF, @r)')
  itShouldParseTheColorWithVariables('fadeout(@c, @r)', {
    '@c':
      value: '0x7800FFFF'
    '@r':
      value: '0.5'
  }, 0, 255, 255, 1)
  itShouldParseTheColorWithVariables('fadeout(@a, @r)', {
    '@a':
      value: 'rgba(@c, 1)'
    '@c':
      value: '0x7800FFFF'
    '@r':
      value: '0.5'
  }, 0, 255, 255, 1)

  itShouldParseTheColor('saturate(#855, 20%)', 158, 63, 63)
  itShouldParseTheColor('saturate(#855, 0.2)', 158, 63, 63)
  itShouldParseTheColorAsInvalid('saturate(#855, @r)')
  itShouldParseTheColorWithVariables('saturate(@c, @r)', {
    '@c':
      value: '#855'
    '@r':
      value: '0.2'
  }, 158, 63, 63)
  itShouldParseTheColorWithVariables('saturate(@a, @r)', {
    '@a':
      value: 'rgba(@c, 1)'
    '@c':
      value: '#855'
    '@r':
      value: '0.2'
  }, 158, 63, 63)

  itShouldParseTheColor('desaturate(#9e3f3f, 20%)', 136, 85, 85)
  itShouldParseTheColor('desaturate(#9e3f3f, 0.2)', 136, 85, 85)
  itShouldParseTheColor('desaturate(#9e3f3f, .2)', 136, 85, 85)
  itShouldParseTheColorAsInvalid('desaturate(#9e3f3f, @r)')
  itShouldParseTheColorWithVariables('desaturate(@c, @r)', {
    '@c':
      value: '#9e3f3f'
    '@r':
      value: '0.2'
  }, 136, 85, 85)
  itShouldParseTheColorWithVariables('desaturate(@a, @r)', {
    '@a':
      value: 'rgba(@c, 1)'
    '@c':
      value: '#9e3f3f'
    '@r':
      value: '0.2'
  }, 136, 85, 85)


  itShouldParseTheColor('grayscale(#9e3f3f)', 111, 111, 111)
  itShouldParseTheColor('greyscale(#9e3f3f)', 111, 111, 111)
  itShouldParseTheColorAsInvalid('grayscale(@c)')
  itShouldParseTheColorWithVariables('grayscale(@c)', {
    '@c':
      value: '#9e3f3f'
  }, 111, 111, 111)
  itShouldParseTheColorWithVariables('grayscale(@a)', {
    '@a':
      value: 'rgba(@c, 1)'
    '@c':
      value: '#9e3f3f'
  }, 111, 111, 111)

  itShouldParseTheColor('invert(#9e3f3f)', 97, 192, 192)
  itShouldParseTheColorAsInvalid('invert(@c)')
  itShouldParseTheColorWithVariables('invert(@c)', {
    '@c':
      value: '#9e3f3f'
  }, 97, 192, 192)
  itShouldParseTheColorWithVariables('invert(@a)', {
    '@a':
      value: 'rgba(@c, 1)'
    '@c':
      value: '#9e3f3f'
  }, 97, 192, 192)

  itShouldParseTheColor('adjust-hue(#811, 45deg)', 136, 106, 17)
  itShouldParseTheColor('adjust-hue(#811, -45deg)', 136, 17, 106)
  itShouldParseTheColor('adjust-hue(#811, 45%)', 136, 106, 17)
  itShouldParseTheColor('adjust-hue(#811, -45%)', 136, 17, 106)
  itShouldParseTheColorAsInvalid('adjust-hue($c, $r)')
  itShouldParseTheColorWithVariables('adjust-hue($c, $r)', {
    '$c':
      value: '#811'
    '$r':
      value: '-45deg'
  }, 136, 17, 106)
  itShouldParseTheColorWithVariables('adjust-hue($a, $r)', {
    '$a':
      value: 'rgba($c, 0.5)'
    '$c':
      value: '#811'
    '$r':
      value: '-45deg'
  }, 136, 17, 106, 0.5)

  itShouldParseTheColor('mix(#f00, #00f)', 127, 0, 127)
  itShouldParseTheColor('mix(#f00, #00f, 25%)', 63, 0, 191)
  itShouldParseTheColorAsInvalid('mix($a, $b, $r)')
  itShouldParseTheColorWithVariables('mix($a, $b, $r)', {
    '$a':
      value: '#f00'
    '$b':
      value: '#00f'
    '$r':
      value: '25%'
  }, 63, 0, 191)
  itShouldParseTheColorWithVariables('mix($c, $d, $r)', {
    '$a':
      value: '#f00'
    '$b':
      value: '#00f'
    '$c':
      value: 'rgba($a, 1)'
    '$d':
      value: 'rgba($b, 1)'
    '$r':
      value: '25%'
  }, 63, 0, 191)

  itShouldParseTheColor('tint(#fd0cc7,66%)', 254, 172, 235)
  itShouldParseTheColorAsInvalid('tint($c,$r)')
  itShouldParseTheColorWithVariables('tint($c,$r)', {
    '$c':
      value: '#fd0cc7'
    '$r':
      value: '66%'
  }, 254, 172, 235)
  itShouldParseTheColorWithVariables('tint($c,$r)', {
    '$a':
      value: '#fd0cc7'
    '$c':
      value: 'rgba($a, 0.9)'
    '$r':
      value: '66%'
  }, 254, 172, 235, 0.9)

  itShouldParseTheColor('shade(#fd0cc7,66%)', 86, 4, 67)
  itShouldParseTheColorAsInvalid('shade($c,$r)')
  itShouldParseTheColorWithVariables('shade($c,$r)', {
    '$c':
      value: '#fd0cc7'
    '$r':
      value: '66%'
  }, 86, 4, 67)
  itShouldParseTheColorWithVariables('shade($c,$r)', {
    '$a':
      value: '#fd0cc7'
    '$c':
      value: 'rgba($a, 0.9)'
    '$r':
      value: '66%'
  }, 86, 4, 67, 0.9)

  itShouldParseTheColor('color(#fd0cc7 tint(66%))', 254, 172, 236)

  itShouldParseTheColor('adjust-color(#102030, $red: -5, $blue: 5)', 11, 32, 53)
  itShouldParseTheColor('adjust-color(hsl(25, 100%, 80%), $lightness: -30%, $alpha: -0.4)', 255, 106, 0, 0.6)
  itShouldParseTheColorAsInvalid('adjust-color($c, $red: $a, $blue: $b)')
  itShouldParseTheColorWithVariables('adjust-color($c, $red: $a, $blue: $b)', {
    '$a':
      value: '-5'
    '$b':
      value: '5'
    '$c':
      value: '#102030'
  }, 11, 32, 53)
  itShouldParseTheColorWithVariables('adjust-color($d, $red: $a, $blue: $b)', {
    '$a':
      value: '-5'
    '$b':
      value: '5'
    '$c':
      value: '#102030'
    '$d':
      value: 'rgba($c, 1)'
  }, 11, 32, 53)

  itShouldParseTheColor('scale-color(rgb(200, 150, 170), $green: -40%, $blue: 70%)', 200, 90, 230)
  itShouldParseTheColor('change-color(rgb(200, 150, 170), $green: 40, $blue: 70)', 200, 40, 70)
  itShouldParseTheColorAsInvalid('scale-color($c, $green: $a, $blue: $b)')
  itShouldParseTheColorWithVariables('scale-color($c, $green: $a, $blue: $b)', {
    '$a':
      value: '-40%'
    '$b':
      value: '70%'
    '$c':
      value: 'rgb(200, 150, 170)'
  }, 200, 90, 230)
  itShouldParseTheColorWithVariables('scale-color($d, $green: $a, $blue: $b)', {
    '$a':
      value: '-40%'
    '$b':
      value: '70%'
    '$c':
      value: 'rgb(200, 150, 170)'
    '$d':
      value: 'rgba($c, 1)'
  }, 200, 90, 230)
