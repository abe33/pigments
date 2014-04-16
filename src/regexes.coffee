int = '\\d+'
float = "#{int}(?:\\.#{int})?"
percent = "#{float}%"

module.exports =
  int: int
  float: float
  percent: percent
  intOrPercent: "(#{int}|#{percent})"
  floatOrPercent: "(#{float}|#{percent})"
  comma: '\\s*,\\s*'
  notQuote: "[^\"'\n]*"
  hexa: '[\\da-fA-F]'
  ps: '\\(\\s*'
  pe: '\\s*\\)'
