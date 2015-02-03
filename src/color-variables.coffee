Color = require './color-model'

Color.addVariableExpression 'less', '(@[a-zA-Z0-9\\-_]+)\\s*:\\s*([^;\\n]+);?'
Color.addVariableExpression 'scss', '(\\$[a-zA-Z0-9\\-_]+):\\s*(.*?)(\\s*!default)?;'
Color.addVariableExpression 'sass', '(\\$[a-zA-Z0-9\\-_]+):\\s*(.*?)(\\s*!default)?$'
Color.addVariableExpression 'stylus', '([a-zA-Z_$][a-zA-Z0-9\\-_]*)\\s*=\\s*([^\\n;]*);?$'
