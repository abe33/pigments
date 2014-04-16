
module.exports =
  strip: (str) -> str.replace(/\s+/g, '')
  clamp: (n) -> Math.min(1, Math.max(0, n))
  clampInt: (n, max=100) -> Math.min(max, Math.max(0, n))
  parseIntOrPercent: (value) ->
    if value.indexOf('%') isnt -1
      value = Math.round(parseFloat(value) * 2.55)
    else
      value = parseInt(value)

  parseFloatOrPercent: (amount) ->
    if amount.indexOf('%') isnt -1
      parseFloat(amount) / 100
    else
      parseFloat(amount)
