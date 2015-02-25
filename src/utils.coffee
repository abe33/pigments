
utils =
  strip: (str) -> str.replace(/\s+/g, '')

  clamp: (n) -> Math.min(1, Math.max(0, n))

  clampInt: (n, max=100) -> Math.min(max, Math.max(0, n))

  readFloat: (value, vars={}, color) ->
    res = parseFloat(value)
    if isNaN(res) and vars[value]?
      color.usedVariables.push(value)
      res = parseFloat(vars[value].value)
    res

  readInt: (value, vars={}, color, base=10) ->
    res = parseInt(value, base)
    if isNaN(res) and vars[value]?
      color.usedVariables.push(value)
      res = parseInt(vars[value].value, base)
    res

  readIntOrPercent: (value, vars={}, color) ->
    if not /\d+/.test(value) and vars[value]?
      color.usedVariables.push(value)
      value = vars[value].value

    return NaN unless value?

    if value.indexOf('%') isnt -1
      res = Math.round(parseFloat(value) * 2.55)
    else
      res = parseInt(value)

    res

  readFloatOrPercent: (amount, vars={}, color) ->
    if not /\d+/.test(amount) and vars[amount]?
      color.usedVariables.push(amount)
      amount = vars[amount].value

    return NaN unless amount?

    if amount.indexOf('%') isnt -1
      res = parseFloat(amount) / 100
    else
      res = parseFloat(amount)

    res

  findClosingIndex: (s, startIndex=0, openingChar="[", closingChar="]") ->
    index = startIndex
    nests = 1

    while nests && index < s.length
      curStr = s.substr index++, 1

      if curStr is closingChar
        nests--
      else if curStr is openingChar
        nests++

    if nests is 0 then index - 1 else -1

  split: (s, sep=",") ->
    a = []
    l = s.length
    i = 0
    start = 0
    while i < l
      c = s.substr(i, 1)

      switch(c)
        when "("
          i = utils.findClosingIndex s, i + 1, c, ")"
        when "["
          i = utils.findClosingIndex s, i + 1, c, "]"
        when ""
          i = utils.findClosingIndex s, i + 1, c, ""
        when sep
          a.push utils.strip s.substr start, i - start
          start = i + 1

      i++

    a.push utils.strip s.substr start, i - start
    a


module.exports = utils
