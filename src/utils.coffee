
utils =
  strip: (str) -> str.replace(/\s+/g, '')
  clamp: (n) -> Math.min(1, Math.max(0, n))
  clampInt: (n, max=100) -> Math.min(max, Math.max(0, n))
  parseFloat: (value, vars={}) ->
    res = parseFloat(value)
    res = parseFloat(vars[value]?.value) if isNaN(res)
    res

  parseInt: (value, base, vars={}) ->
    [base, vars] = [10, base] if typeof base is 'object'
    res = parseInt(value, base)
    res = parseInt(vars[value]?.value, base) if isNaN(res)
    res

  parseIntOrPercent: (value, vars={}) ->
    value = vars[value]?.value unless /\d+/.test(value)
    return NaN unless value?

    if value.indexOf('%') isnt -1
      res = Math.round(parseFloat(value) * 2.55)
    else
      res = parseInt(value)

    res

  parseFloatOrPercent: (amount, vars={}) ->
    amount = vars[amount]?.value unless /\d+/.test(amount)
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
