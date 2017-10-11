require 'logger'

class Parser

  def initialize (tokenStream)
    @ts = tokenStream
    @ts.fill

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @logger.info("Initialized parser.")
  end
  
  def nextToken ()
    @ts.lookahead
  end
  
  def consume ()
    @ts.consume
  end

  def match (kind)
    if nextToken.kind == kind
      @ts.consume
    else
      puts "Error: No match. Expecting '#{kind}' but found '#{nextToken.kind}' instead."
    end
  end
  
  def option (kind)
    t = nextToken
    if t.kind == kind
      @ts.consume
    end
  end
  
  def setLogLevel(level)
    @logger.level = level
  end

  def start ()
    @logger.debug("start")
    done = false
    n = Node.new(:ROOT)
    while !done
      t = nextToken
      case t.kind
      when 'val', 'var', 'def', 'fun', 'class'
        n.addChild(declaration)
      when :ID, 'if', 'return', 'while', ';',
              '()', :BOOLEAN, :INTEGER, :FLOAT, :IMAGINARY, '(', '['
        n.addChild(statement)
      when 'EOF'
        done = true
      else
        puts "ERROR in start()"
        done = true
      end
    end
    n
  end

  # ********** Declarations **********

  def declaration ()
    @logger.debug("declaration")
    case nextToken.kind
    when 'val'
      n = valueDecl
    when 'var'
      n = variableDecl
    when 'def'
      n = functionDecl
    when 'fun'
      n = functionDecl
    when 'class'
      n = classDecl
    end
    n
  end

  def valueDecl ()
    @logger.debug("valueDecl")
    n = Node.new(:VALUE_DECL)
    match('val')
    n.addChild(identifier)
    match('=')
    n.addChild(expression)
    match(';')
    n
  end

  def variableDecl ()
    @logger.debug("variableDecl")
    n = Node.new(:VARIABLE_DECL)
    match('var')
    n.addChild(identifier)
    match('=')
    n.addChild(expression)
    match(';')
    n
  end
  
  def functionDecl ()
    @logger.debug("functionDecl")
    n = Node.new(:FUNCTION_DECL)
    match('fun')
    n.addChild(identifier)
    match('(')
    if nextToken.kind == :ID
      n.addChild(parameters)
    end
    match(')')
    match('=')
    n.addChild(functionBody)
    n
  end

  def parameters ()
    @logger.debug("parameters")
    n = Node.new(:PARAMETERS)
    n.addChild(parameter)
    while nextToken.kind == ','
      @ts.consume
      n.addChild(parameter)
    end
    # Allow trailing comma
    option(',')
    n
  end

  def parameter ()
    @logger.debug("parameter")
    n = Node.new(:PARAMETER)
    n.addChild(identifier)
    n
  end
  
  def functionBody ()
    @logger.debug("functionBody")
    n = Node.new(:FUNCTION_BODY)
    if nextToken.kind == '{'
      n.addChild(block)
    else
      # Manually insert a block
      p = Node.new(:BLOCK)
      p.addChild(blockElement)
      n.addChild(p)
    end
    n
  end

  def block ()
    @logger.debug("block")
    # Not sure if this should be considered a statement or an expression
    # A function call is always an expression, so this should probably be an expression
    n = Node.new(:BLOCK)
    match('{')
    while nextToken.kind != '}'
      n.addChild(blockElement)
    end
    match('}')
    n
  end

  def blockElement ()
    @logger.debug("blockElement")
    case nextToken.kind
    when 'val', 'var', 'def', 'fun', 'class'
      # Not sure class declarations should be valid inside blocks - maybe only inside class bodies
      n = declaration
    else
      n = statement
    end
    n
  end

  def classDecl ()
    @logger.debug("classDecl")
    n = Node.new(:CLASS_DECL)
    match('class')
    n.addChild(identifier)
    n.addChild(classBody)
    n
  end
  
  def classBody ()
    @logger.debug("classBody")
    n = Node.new(:CLASS_BODY)
    match('{')
    match('}')
  end
  
  # ********** Statements **********

  def statement ()
    @logger.debug("statement")
    case nextToken.kind
    when 'break'
      n = breakStmt
    when 'continue'
      n = continueStmt
    when 'do'
      n = doStmt
    when ';'
      n = emptyStmt
    when 'for'
      n = forStmt
    when 'if'
      n = ifStmt
    when 'return'
      n = returnStmt
    when 'while'
      n = whileStmt
    else
      n = expressionStmt
    end
    n
  end

  def breakStmt ()
    @logger.debug("breakStmt")
    n = Node.new(:BREAK_STMT)
    match('break')
    match(';')
    n
  end

  def continueStmt ()
    @logger.debug("continueStmt")
    n = Node.new(:CONTINUE_STMT)
    match('continue')
    match(';')
    n
  end

  def doStmt ()
    @logger.debug("doStmt")
    n = Node.new(:DO_STMT)
    match('do')
    match('(')
    n.addChild(expression)
    match(')')
    if nextToken.kind == '{'
      n.addChild(block)
    else
      n.addChild(statement)
    end
    n
  end

  def emptyStmt ()
    @logger.debug("emptyStmt")
    # ultimately, should this evaluate to ()? e.g. equivalent to ();
    n = Node.new(:EMPTY_STMT)
    match(';')
    n
  end
  
  def forStmt ()
    @logger.debug("forStmt")
    n = Node.new(:FOR_STMT)
    match('for')
    match('(')
    # Need to parse "(i in 0..10)" format
    n.addChild(expression)
    match(')')
    if nextToken.kind == '{'
      n.addChild(block)
    else
      n.addChild(statement)
    end
    n
  end

  def ifStmt ()
    # The ifStmt appears here to avoid the need for a ';' at the end, which would be required for an exprStmt
    @logger.debug("ifStmt")
    n = Node.new(:IF_STMT)
    n.addChild(ifExpr)
    n
  end

  def returnStmt ()
    @logger.debug("returnStmt")
    n = Node.new(:RETURN_STMT)
    match('return')
    if nextToken.kind == ';'
      # Return unit implicitly
      p = Node.new(:EXPRESSION)
      q = Node.new(:UNIT_LITERAL)
      p.addChild(q)
      n.addChild(p)
    else
      n.addChild(expression)
    end
    match(';')
    n
  end

  def whileStmt ()
    @logger.debug("whileStmt")
    n = Node.new(:WHILE_STMT)
    match('while')
    match('(')
    n.addChild(expression)
    match(')')
    if nextToken.kind == '{'
      n.addChild(block)
    else
      # Manually insert a block
      p = Node.new(:BLOCK)
      p.addChild(blockElement)
      n.addChild(p)
    end
    n
  end

  def expressionStmt ()
    @logger.debug("expressionStmt")
    n = Node.new(:EXPRESSION_STMT)
    n.addChild(expression)
    match(';')
    n
  end

  # ********** Expressions **********
  
  def expression ()
    @logger.debug("expression")
    n = Node.new(:EXPRESSION)
    t = nextToken
    if t.kind == 'if'
      n.addChild(ifExpr)
    else
      n.addChild(assignmentExpr)
    end
    n
  end
  
  def ifExpr ()
    # Draft node implementation
    @logger.debug("ifExpr")
    n = Node.new(:IF_EXPR)
    match('if')
    match('(')
    n.addChild(expression)
    match(')')
    if nextToken.kind == '{'
      n.addChild(block)
    else
      # Perhaps should insert a block node manually here?
      n.addChild(blockElement)
    end
    if nextToken.kind == 'else'
      n.addChild(elseClause)
    end
    n
  end

  def elseClause ()
    # Needs node implementation
    @logger.debug("elseClause")
    match('else')
    if nextToken.kind == '{'
      n = block
    else
      n = blockElement
    end
    n
  end

  def assignmentExpr ()
    @logger.debug("assignmentExpr")
    # Might need to limit this to lvalues
    # This is written to be right-associative
    n = logicalOrExpr
    t = nextToken
    if t.kind == '=' then
      match('=')
      p = Node.new(:ASSIGNMENT_EXPR)
      p.addChild(n)
      p.addChild(assignmentExpr)
      n = p
    end
    n
  end

  def logicalOrExpr ()
    @logger.debug("logicalOrExpr")
    n = logicalAndExpr
    t = nextToken
    while t.kind == '||'
      match('||')
      p = Node.new(:LOGICAL_OR_EXPR)
      p.addChild(n)
      p.addChild(logicalAndExpr)
      n = p
      t = nextToken
    end
    n
  end

  def logicalAndExpr ()
    @logger.debug("logicalAndExpr")
    n = bitwiseOrExpr
    t = nextToken
    while t.kind == '&&'
      match('&&')
      p = Node.new(:LOGICAL_AND_EXPR)
      p.addChild(n)
      p.addChild(bitwiseOrExpr)
      n = p
      t = nextToken
    end
    n
  end
  
  def bitwiseOrExpr ()
    @logger.debug("bitwiseOrExpr")
    n = bitwiseXorExpr
    t = nextToken
    while t.kind == '|'
      match('|')
      p = Node.new(:BINARY_EXPR)
      p.setText('|')
      p.addChild(n)
      p.addChild(bitwiseXorExpr)
      n = p
      t = nextToken
    end
    n
  end

  def bitwiseXorExpr ()
    @logger.debug("bitwiseXorExpr")
    n = bitwiseAndExpr
    t = nextToken
    while t.kind == '^'
      match('^')
      p = Node.new(:BINARY_EXPR)
      p.setText('^')
      p.addChild(n)
      p.addChild(bitwiseAndExpr)
      n = p
      t = nextToken
    end
    n
  end

  def bitwiseAndExpr ()
    @logger.debug("bitwiseAndExpr")
    n = equalityExpr
    t = nextToken
    while t.kind == '&'
      match('&')
      p = Node.new(:BINARY_EXPR)
      p.setText('&')
      p.addChild(n)
      p.addChild(equalityExpr)
      n = p
      t = nextToken
    end
    n
  end

  def equalityExpr ()
    @logger.debug("equalityExpr")
    n = relationalExpr
    t = nextToken
    while t.kind == '==' || t.kind == '!='
      match(t.kind)
      p = Node.new(:BINARY_EXPR)
      p.setText(t.text)
      p.addChild(n)
      p.addChild(relationalExpr)
      n = p
      t = nextToken
    end
    n
  end

  def relationalExpr ()
    @logger.debug("relationalExpr")
    n = shiftExpr
    t = nextToken
    while t.kind == '>' || t.kind == '<' || t.kind == '>=' || t.kind == '<='
      match(t.kind)
      p = Node.new(:BINARY_EXPR)
      p.setText(t.text)
      p.addChild(n)
      p.addChild(shiftExpr)
      n = p
      t = nextToken
    end
    n
  end

  def shiftExpr ()
    @logger.debug("shiftExpr")
    n = additiveExpr
    t = nextToken
    # The >>> operator would perform a logical right shift
    # We are not defining that for now due to the complexity
    while t.kind == '<<' || t.kind == '>>'
      match(t.kind)
      p = Node.new(:BINARY_EXPR)
      p.setText(t.text)
      p.addChild(n)
      p.addChild(additiveExpr)
      n = p
      t = nextToken
    end
    n
  end

  def additiveExpr ()
    @logger.debug("additiveExpr")
    n = multiplicativeExpr
    t = nextToken
    while t.kind == '+' || t.kind == '-'
      match(t.kind)
      p = Node.new(:BINARY_EXPR)
      p.setText(t.text)
      p.addChild(n)
      p.addChild(multiplicativeExpr)
      n = p
      t = nextToken
    end
    n
  end
  
  def multiplicativeExpr ()
    @logger.debug("multiplicativeExpr")
    n = unaryExpr
    t = nextToken
    while t.kind == '*' || t.kind == '/' || t.kind == '%'
      match(t.kind)
      p = Node.new(:BINARY_EXPR)
      p.setText(t.text)
      p.addChild(n)
      p.addChild(unaryExpr)
      n = p
      t = nextToken
    end
    n
  end
  
  def unaryExpr ()
    @logger.debug("unaryExpr")
    t = nextToken
    if t.kind == '-'
      match('-')
      n = Node.new(:UNARY_EXPR)
      n.setText('-')
      n.addChild(unaryExpr)
    else
      n = unaryExprNotPlusMinus
    end
    n
  end

  def unaryExprNotPlusMinus ()
    @logger.debug("unaryExprNotPlusMinus")
    t = nextToken
    if t.kind == '~'
      match('~')
      n = Node.new(:UNARY_EXPR)
      n.setText('~')
      n.addChild(unaryExpr)
    elsif t.kind == '!'
      match('!')
      n = Node.new(:UNARY_EXPR)
      n.setText('!')
      n.addChild(unaryExpr)
    else
      n = primaryExpr
    end
    n
  end

  def primaryExpr ()
    @logger.debug("primaryExpr")
    t = nextToken
    case t.kind
    when :ID
      n = idExpr
    when '('
      n = parenthesizedExpr
    else
      n = literal
    end
    n
  end

  def idExpr ()
    @logger.debug("idExpr")
    n = identifier
    t = nextToken
    if (t.kind == '(' || t.kind == '[' || t.kind == '.')
      p = idTail(n)
      n = p
    end
    n
  end

  def idTail (node)
    @logger.debug("idTail")
    case nextToken.kind
    when '('
      n = functionCall(node)
    when '['
      # This notation is also used to access other aggregations such as tuples and hashes
      n = arrayAccess(node)
    when '.'
      n = objectAccess(node)
    end
    t = nextToken
    if (t.kind == '(' || t.kind == '[' || t.kind == '.')
      p = idTail(n)
      n = p
    end
    n
  end

  def functionCall (node)
    @logger.debug("functionCall")
    n = Node.new(:FUNCTION_CALL)
    n.addChild(node)
    match('(')
    if expression? nextToken
      n.addChild(arguments)
    end
    match(')')
    n
  end

  def expression? (token)
    k = token.kind
    if (k == :BOOLEAN ||
        k == :INTEGER ||
        k == :FLOAT ||
        k == :IMAGINARY ||
        k == :ID ||
        k == '(' ||
        k == '[' ||
        k == '{')
      true
    else
      false
    end
  end

  def arguments ()
    @logger.debug("arguments")
    n = Node.new(:ARGUMENTS)
    n.addChild(expression)
    while nextToken.kind == ','
      consume
      n.addChild(expression)
    end
    n
  end

  def arrayAccess (node)
    @logger.debug("arrayAccess")
    n = Node.new(:ARRAY_ACCESS)
    n.addChild(node)
    match('[')
    n.addChild(expression)
    match(']')
    n
  end

  def objectAccess (node)
    @logger.debug("objectAccess")
    n = Node.new(:OBJECT_ACCESS)
    n.addChild(node)
    match('.')
    n.addChild(identifier)
    n
  end

  def identifier ()
    @logger.debug("identifier")
    t = nextToken
    match(:ID)
    n = Node.new(:IDENTIFIER)
    n.setText(t.text)
    n
  end

  def parenthesizedExpr ()
    @logger.debug("parenthesizedExpr")
    # This could either be a tuple or a plain expression enclosed in parenthesis
    match('(')
    n = expression
    if nextToken.kind == ','
      p = Node.new(:TUPLE_LITERAL)
      p.addChild(n)
      n = p
    end
    while nextToken.kind == ','
      consume
      # Check for optional trailing comma
      if nextToken.kind != ')'
        n.addChild(expression)
      end
    end
    match(')')
    n
  end

  # ********** Literals **********

  def literal ()
    @logger.debug("literal")
    case nextToken.kind
    when :NULL
      n = nullLiteral
    when '()'
      n = unitLiteral
    when :BOOLEAN
      n = booleanLiteral
    when :INTEGER
      n = integerLiteral
    when :FLOAT
      n = floatLiteral
    when :IMAGINARY
      n = imaginaryLiteral
    when '['
      n = arrayLiteral
    when '{'
      n = hashLiteral
    else
      puts "ERROR - literal not found!"
      exit
    end
    n
  end

  def nullLiteral ()
    @logger.debug("nullLiteral")
    n = Node::NULL_LITERAL
    match(:NULL)
    n
  end

  def unitLiteral ()
    @logger.debug("unitLiteral")
    n = Node::UNIT_LITERAL
    match('()')
    n
  end
  
  def booleanLiteral ()
    @logger.debug("booleanLiteral")
    n = Node.new(:BOOLEAN_LITERAL)
    n.setText(nextToken.text)
    match(:BOOLEAN)
    n
  end

  def integerLiteral ()
    @logger.debug("integerLiteral")
    n = Node.new(:INTEGER_LITERAL)
    n.setText(nextToken.text)
    match(:INTEGER)
    n
  end

  def floatLiteral ()
    @logger.debug("floatLiteral")
    n = Node.new(:FLOAT_LITERAL)
    n.setText(nextToken.text)
    match(:FLOAT)
    n
  end

  def imaginaryLiteral ()
    @logger.debug("imaginaryLiteral")
    n = Node.new(:IMAGINARY_LITERAL)
    n.setText(nextToken.text)
    match(:IMAGINARY)
    n
  end

  def arrayLiteral ()
    @logger.debug("arrayLiteral")
    n = Node.new(:ARRAY_LITERAL)
    match('[')
    if nextToken.kind != ']'
      n.addChild(arrayElements)
    end
    match(']')
    n
  end

  def arrayElements ()
    @logger.debug("arrayElements")
    n = Node.new(:ARRAY_ELEMENTS)
    n.addChild(arrayElement)
    while nextToken.kind == ','
      consume
      # Check for optional trailing comma
      if nextToken.kind != ']'
        n.addChild(arrayElement)
      end
    end
    n
  end

  def arrayElement ()
    @logger.debug("arrayElement")
    n = expression
    n
  end

  def hashLiteral ()
    @logger.debug("hashLiteral")
  end

end #class

