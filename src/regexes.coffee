int = '\\d+'
float = "\\d*(?:\\.#{int})?"
percent = "#{float}%"

module.exports =
  int: int
  float: float
  percent: percent
  intOrPercent: "(#{percent}|#{int})"
  floatOrPercent: "(#{percent}|#{float})"
  comma: '\\s*,\\s*'
  notQuote: "[^\"'\n]*"
  hexa: '[\\da-fA-F]'
  ps: '\\(\\s*'
  pe: '\\s*\\)'
