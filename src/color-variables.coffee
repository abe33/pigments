Color = require './color-model'

Color.addVariableExpression 'less', '@[a-zA-Z0-9-_]+', '\\s*:', '.*;'
