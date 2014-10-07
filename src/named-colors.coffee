
# Internal: A simple mixin that creates a `namedColors` {Object} in the
# class it extends that contains the color codes of the whole SVG palette.
module.exports =
class NamedColors
  @extend: (Color) ->
    Color.namedColors = {}

    colors =
      alice_blue: '#f0f8ff'
      antique_white: '#faebd7'
      aqua: '#00ffff'
      aqua_marine: '#7fffd4'
      azure: '#f0ffff'
      beige: '#f5f5dc'
      bisque: '#ffe4c4'
      black: '#000000'
      blanched_almond: '#ffebcd'
      blue: '#0000ff'
      blue_violet: '#8a2be2'
      brown: '#a52a2a'
      burly_wood: '#deb887'
      cadet_blue: '#5f9ea0'
      chartreuse: '#7fff00'
      chocolate: '#d2691e'
      coral: '#ff7f50'
      cornflower_blue: '#6495ed'
      corn_silk: '#fff8dc'
      crimson: '#dc143c'
      cyan: '#00ffff'
      dark_blue: '#00008b'
      dark_cyan: '#008b8b'
      dark_goldenrod: '#b8860b'
      dark_gray: '#a9a9a9'
      dark_green: '#006400'
      dark_grey: '#a9a9a9'
      dark_khaki: '#bdb76b'
      dark_magenta: '#8b008b'
      dark_olivegreen: '#556b2f'
      dark_orange: '#ff8c00'
      dark_orchid: '#9932cc'
      dark_red: '#8b0000'
      dark_salmon: '#e9967a'
      dark_seagreen: '#8fbc8f'
      dark_slateblue: '#483d8b'
      dark_slategray: '#2f4f4f'
      dark_slategrey: '#2f4f4f'
      dark_turquoise: '#00ced1'
      dark_violet: '#9400d3'
      deep_pink: '#ff1493'
      deep_skyblue: '#00bfff'
      dim_gray: '#696969'
      dim_grey: '#696969'
      dodger_blue: '#1e90ff'
      fire_brick: '#b22222'
      floral_white: '#fffaf0'
      forest_green: '#228b22'
      fuchsia: '#ff00ff'
      gainsboro: '#dcdcdc'
      ghost_white: '#f8f8ff'
      gold: '#ffd700'
      golden_rod: '#daa520'
      gray: '#808080'
      green: '#008000'
      green_yellow: '#adff2f'
      grey: '#808080'
      honey_dew: '#f0fff0'
      hot_pink: '#ff69b4'
      indian_red: '#cd5c5c'
      indigo: '#4b0082'
      ivory: '#fffff0'
      khaki: '#f0e68c'
      lavender: '#e6e6fa'
      lavender_blush: '#fff0f5'
      lawn_green: '#7cfc00'
      lemon_chiffon: '#fffacd'
      light_blue: '#add8e6'
      light_coral: '#f08080'
      light_cyan: '#e0ffff'
      light_goldenrodyellow: '#fafad2'
      light_gray: '#d3d3d3'
      light_green: '#90ee90'
      light_grey: '#d3d3d3'
      light_pink: '#ffb6c1'
      light_salmon: '#ffa07a'
      light_seagreen: '#20b2aa'
      light_skyblue: '#87cefa'
      light_slategray: '#778899'
      light_slategrey: '#778899'
      light_steelblue: '#b0c4de'
      light_yellow: '#ffffe0'
      lime: '#00ff00'
      lime_green: '#32cd32'
      linen: '#faf0e6'
      magenta: '#ff00ff'
      maroon: '#800000'
      medium_aquamarine: '#66cdaa'
      medium_blue: '#0000cd'
      medium_orchid: '#ba55d3'
      medium_purple: '#9370db'
      medium_seagreen: '#3cb371'
      medium_slateblue: '#7b68ee'
      medium_springgreen: '#00fa9a'
      medium_turquoise: '#48d1cc'
      medium_violetred: '#c71585'
      midnight_blue: '#191970'
      mint_cream: '#f5fffa'
      misty_rose: '#ffe4e1'
      moccasin: '#ffe4b5'
      navajo_white: '#ffdead'
      navy: '#000080'
      old_lace: '#fdf5e6'
      olive: '#808000'
      olive_drab: '#6b8e23'
      orange: '#ffa500'
      orange_red: '#ff4500'
      orchid: '#da70d6'
      pale_golden_rod: '#eee8aa'
      pale_green: '#98fb98'
      pale_turquoise: '#afeeee'
      pale_violetred: '#db7093'
      papaya_whip: '#ffefd5'
      peach_puff: '#ffdab9'
      peru: '#cd853f'
      pink: '#ffc0cb'
      plum: '#dda0dd'
      powder_blue: '#b0e0e6'
      purple: '#800080'
      red: '#ff0000'
      rosy_brown: '#bc8f8f'
      royal_blue: '#4169e1'
      saddle_brown: '#8b4513'
      salmon: '#fa8072'
      sandy_brown: '#f4a460'
      sea_green: '#2e8b57'
      sea_shell: '#fff5ee'
      sienna: '#a0522d'
      silver: '#c0c0c0'
      sky_blue: '#87ceeb'
      slate_blue: '#6a5acd'
      slate_gray: '#708090'
      slate_grey: '#708090'
      snow: '#fffafa'
      spring_green: '#00ff7f'
      steel_blue: '#4682b4'
      tan: '#d2b48c'
      teal: '#008080'
      thistle: '#d8bfd8'
      tomato: '#ff6347'
      turquoise: '#40e0d0'
      violet: '#ee82ee'
      yellow_green: '#9acd32'
      wheat: '#f5deb3'
      white: '#ffffff'
      white_smoke: '#f5f5f5'
      yellow: '#ffff00'

    for k,v of colors
      a = k.split('_')
      Color.namedColors[a.map((s) -> s[0].toUpperCase() + s[1..-1] ).join('')] =
      Color.namedColors[a.join('').toUpperCase()] =
      Color.namedColors[a.join('')] = v
