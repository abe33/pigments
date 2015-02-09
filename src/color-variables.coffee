Color = require './color-model'
{strip} = require './utils'

Color.addVariableExpression 'less', '(@[a-zA-Z0-9\\-_]+)\\s*:\\s*([^;\\n]+);?'

Color.addVariableExpression 'scss', '(\\$[a-zA-Z0-9\\-_]+):\\s*(.*?)(\\s*!default)?;'

Color.addVariableExpression 'sass', '(\\$[a-zA-Z0-9\\-_]+):\\s*(.*?)(\\s*!default)?$'

Color.addVariableExpression 'stylus_hash', '([a-zA-Z_$][a-zA-Z0-9\\-_]*)\\s*=\\s*\\{([^=]*)\\}', (match, start, end, solver) ->
  buffer = ''
  [match, name, content] = match
  current = match.indexOf(content)
  scope = [name]

  for char in content
    if /\{/.test(char)
      scope.push buffer.replace(/[\s:]/g, '')
      buffer = ''
    else if /\}/.test(char)
      scope.pop()
      return current if scope.length is 0
    else if /[,\n]/.test(char)
      buffer = strip(buffer)
      if buffer.length
        [key, value] = buffer.split(/\s*:\s*/)

        solver.appendResult([
          scope.concat(key).join('.')
          value
          start + current - buffer.length - 1
          start + current
        ])

      buffer = ''
    else
      buffer += char

    current++
  end

Color.addVariableExpression 'stylus', '([a-zA-Z_$][a-zA-Z0-9\\-_]*)\\s*=\\s*([^\\n;]*);?$'
