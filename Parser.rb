require 'logger'

class Parser

  def initialize (tokens)
    @tokens = tokens

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN
    @logger.info("Initialized parser.")

    @plog = ProblemLogger.new
  end
  
  def nextToken ()
    @tokens.lookahead
  end
  
  def consume ()
    @tokens.consume
  end

  def match (kind)
    t = nextToken
    if t.kind == kind
      @tokens.consume
    else
      puts "error recovery mode!"
      # Error recovery strategy for failures to match:
      # First try single-token deletion
      # If that doesn't work, then declare a mismatch and panic
      # This is not fully implemented yet

      # Delete a single token
      @tokens.consume
      # Now try to match again
      t2 = nextToken
      if t2.kind == kind
        # Token t was just extraneous input, consume it
        @tokens.consume
        @plog.error("extraneous input '#{t.kind}', expecting '#{kind}'", t.line, t.column)        
      else
        # This is plain mismatched input -- need to enter panic mode to continue
        # Not full implemented yet
        @tokens.consume # this is supposed to panic
        @plog.error("mismatched input '#{t.kind}', expecting '#{kind}'", t.line, t.column)        
      end
    end
  end
  
  def option (kind)
    t = nextToken
    if t.kind == kind
      @tokens.consume
    end
  end
  
  def setLogLevel (level)
    @logger.level = level
  end

  def problems ()
    @plog
  end

  def start ()
    program
  end

  def program ()
    @logger.debug("program")
    done = false
    n = Node.new(:PROGRAM)
    while !done do
      t = nextToken
      case t.kind
      when 'val', 'var', 'def', 'class', 'object'
        n.addChild(declaration)
      when 'break', 'continue', 'do', ';', 'for', 'print', 'return', 'while'
        n.addChild(statement)
      when 'if', :ID, :NULL, :UNIT, :BOOLEAN, :INTEGER, :FLOAT, :IMAGINARY, :STRING, '(', '[', '{', 'lambda'
        n.addChild(statement)
      when 'EOF'
        done = true
      else
        # Actually, this might be better handled by single-token deletion.
        # But if there are two or more consecutive bad tokens, then single-token
        # deletion wouldn't work and it would become a mismatched input error.
        @plog.error("mismatched input '#{t.text}', expecting declaration or statement", t.line, t.column)
        done = true
      end
    end
    n    
  end

  # DECLARATIONS

  def declaration ()
    case nextToken.kind
    when 'val' then valueDecl
    when 'var' then variableDecl
    when 'def' then functionDecl
    when 'object' then objectDecl
    when 'class' then classDecl
    else
      raise "Parse error in declaration(): Can this ever happen?"
    end
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
    match('def')
    n.addChild(identifier)
    n.addChild(function)
    n
  end
  
  def function ()
    @logger.debug("function")
    n = Node.new(:FUNCTION)
    match('(')
    if nextToken.kind == :ID
      n.addChild(parameters)
    else
      # Add empty parameters node
      n.addChild(Node.new(:PARAMETERS))
    end
    match(')')
    match('=')
    if nextToken.kind == '{'
      n.addChild(blockExpr)
    else
      n.addChild(expression)
      match(';')
    end
    n
  end

  def parameters ()
    @logger.debug("parameters")
    n = Node.new(:PARAMETERS)
    n.addChild(parameter)
    while nextToken.kind == ','
      @tokens.consume
      n.addChild(parameter)
    end
    n
  end

  def parameter ()
    @logger.debug("parameter")
    n = Node.new(:PARAMETER)
    n.addChild(identifier)
    n
  end

  def objectDecl ()
    @logger.debug("objectDecl")
    n = Node.new(:OBJECT_DECL)
    match('object')
    n.addChild(identifier)
    n.addChild(body)
    n
  end

  def body ()
    @logger.debug("body")
    n = Node.new(:BODY)
    match('{')
    while nextToken.kind != '}'
      n.addChild(declaration)
    end
    match('}')
    n
  end

  def classDecl ()
    @logger.debug("classDecl")
    n = Node.new(:CLASS_DECL)
    match('class')
    n.addChild(identifier)
    if nextToken.kind == 'extends'
      match('extends')
      n.addChild(identifier)
    end
    n.addChild(template)
    n
  end

  def template ()
    @logger.debug("template")
    n = Node.new(:TEMPLATE)
    match('{')
    match('}')
  end
  
  def identifier ()
    @logger.debug("identifier")
    t = nextToken
    match(:ID)
    n = Node.new(:IDENTIFIER)
    n.setLine(t.line)
    n.setText(t.text)
    n
  end

  # STATEMENTS

  def statement ()
    @logger.debug("statement")
    n = Node.new(:STATEMENT)
    if nextToken.kind == ';' then
      # Empty statement is a "no-op", equivalent to '();'
      puts "FOUND A NO-OP! *******************************"
      consume
      p = Node.new(:EXPRESSION)
      p.addChild(Node::UNIT_LITERAL)
      n.addChild(p)
    else
      n.addChild(expression)
      match(';')
      # I think this is an example of a syntactic predicate
      # This was just for testing -- I don't think we want to do this
      # Test for last token here
      # pos = @tokens.index
      # tok = @tokens.buffer[pos - 1]
      # puts "last token was #{tok.text}!"
      # puts "next token is #{nextToken.text}!"
      # if tok.text != '}'
      #   match(';')
      # end
    end
    n
  end

  # EXPRESSIONS

  def expression ()
    @logger.debug("expression")
    n = Node.new(:EXPRESSION)
    p =
    case nextToken.kind
    when 'break' then breakExpr
    when 'continue' then continueExpr
    when 'do' then doExpr
    when 'for' then forExpr
    when 'print' then printExpr
    when 'return' then returnExpr
    when 'while' then whileExpr
    else
      assignmentExpr
    end
    n.addChild(p)
    n
  end

  def breakExpr ()
    @logger.debug("breakExpr")
    n = Node.new(:BREAK_EXPR)
    match('break')
    n
  end

  def continueExpr ()
    @logger.debug("continueExpr")
    n = Node.new(:CONTINUE_EXPR)
    match('continue')
    n
  end

  def doExpr ()
    @logger.debug("doExpr")
    n = Node.new(:DO_EXPR)
    match('do')
    n.addChild(expression)
    match('while')
    match('(')
    n.addChild(expression)
    match(')')
    n
  end

  def forExpr ()
    @logger.debug("forExpr")
    n = Node.new(:FOR_EXPR)
    match('for')
    # Need to parse "(i in 0..10)" format
    match('(')
    n.addChild(identifier)
    match('=')
    n.addChild(expression)
    match('to')
    n.addChild(expression)
    match(')')
    n.addChild(expression)
    n
  end

  def printExpr ()
    @logger.debug("printExpr")
    n = Node.new(:PRINT_EXPR)
    match('print')
    n.addChild(expression)
    n
  end

  def returnExpr ()
    @logger.debug("returnExpr")
    n = Node.new(:RETURN_EXPR)
    match('return')
    if nextToken.kind == ';'
      # Return unit implicitly
      # Might want to add debug logging here
      p = Node.new(:EXPRESSION)
      q = Node.new(:UNIT_LITERAL)
      p.addChild(q)
      n.addChild(p)
    else
      n.addChild(expression)
    end
    n
  end

  def whileExpr ()
    @logger.debug("whileExpr")
    n = Node.new(:WHILE_EXPR)
    match('while')
    match('(')
    n.addChild(expression)
    match(')')
    n.addChild(expression)
    n
  end

  def assignmentExpr ()
    # Might need to limit this to lvalues
    # This is written to be right-associative
    # A -> b | b op A
    n = logicalOrExpr
    t = nextToken
    if t.kind == '='  ||
       t.kind == '+=' ||
       t.kind == '-=' ||
       t.kind == '*=' ||
       t.kind == '/=' then
      match(t.kind)
      @logger.debug("assignmentExpr")
      p = Node.new(:ASSIGNMENT_EXPR)
      p.setText(t.text)
      p.addChild(n)
      p.addChild(assignmentExpr)
      n = p
    end
    n
  end

  def logicalOrExpr ()
    n = logicalAndExpr
    t = nextToken
    while t.kind == '||'
      match('||')
      @logger.debug("logicalOrExpr")
      p = Node.new(:LOGICAL_OR_EXPR)
      p.addChild(n)
      p.addChild(logicalAndExpr)
      n = p
      t = nextToken
    end
    n
  end

  def logicalAndExpr ()
    n = bitwiseOrExpr
    t = nextToken
    while t.kind == '&&'
      match('&&')
      @logger.debug("logicalAndExpr")
      p = Node.new(:LOGICAL_AND_EXPR)
      p.addChild(n)
      p.addChild(bitwiseOrExpr)
      n = p
      t = nextToken
    end
    n
  end
  
  def bitwiseOrExpr ()
    n = bitwiseXorExpr
    t = nextToken
    while t.kind == '|'
      match('|')
      @logger.debug("bitwiseOrExpr")
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
    n = bitwiseAndExpr
    t = nextToken
    while t.kind == '^'
      match('^')
      @logger.debug("bitwiseXorExpr")
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
    n = equalityExpr
    t = nextToken
    while t.kind == '&'
      match('&')
      @logger.debug("bitwiseAndExpr")
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
    n = relationalExpr
    t = nextToken
    while t.kind == '==' || t.kind == '!='
      match(t.kind)
      @logger.debug("equalityExpr")
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
    n = shiftExpr
    t = nextToken
    while t.kind == '>'  ||
          t.kind == '<'  ||
          t.kind == '>=' ||
          t.kind == '<=' do
      match(t.kind)
      @logger.debug("relationalExpr")
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
    n = additiveExpr
    t = nextToken
    # The >>> operator would perform a logical right shift
    # We are not defining that for now due to the complexity
    while t.kind == '<<' || t.kind == '>>'
      match(t.kind)
      @logger.debug("shiftExpr")
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
    n = multiplicativeExpr
    t = nextToken
    while t.kind == '+' || t.kind == '-'
      match(t.kind)
      @logger.debug("additiveExpr")
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
    n = unaryExpr
    t = nextToken
    while t.kind == '*' ||
          t.kind == '/' ||
          t.kind == '%' do
      match(t.kind)
      @logger.debug("multiplicativeExpr")
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
    t = nextToken
    if t.kind == '-'
      match('-')
      @logger.debug("unaryExpr")
      n = Node.new(:UNARY_EXPR)
      n.setText('-')
      n.addChild(unaryExpr)
    else
      n = unaryExprNotPlusMinus
    end
    n
  end

  def unaryExprNotPlusMinus ()
    t = nextToken
    if t.kind == '~'
      match('~')
      @logger.debug("unaryExprNotPlusMinus")
      n = Node.new(:UNARY_EXPR)
      n.setText('~')
      n.addChild(unaryExpr)
    elsif t.kind == '!'
      match('!')
      @logger.debug("unaryExprNotPlusMinus")
      n = Node.new(:UNARY_EXPR)
      n.setText('!')
      n.addChild(unaryExpr)
    else
      n = primaryExpr
    end
    n
  end

  def primaryExpr ()
    case nextToken.kind
      when 'if' then ifExpr
      when :ID then nameExpr
      when 'lambda' then lambdaExpr
      when '{' then blockExpr
      when '(' then parenthesizedExpr
      else literal
    end
  end

  def ifExpr ()
    # Draft node implementation
    @logger.debug("ifExpr")
    n = Node.new(:IF_EXPR)
    match('if')
    match('(')
    n.addChild(expression)
    match(')')

    # If expressions are equivalent to the following function
    # if (cond_expr, true_expr, false_expr)
    # Functions can only take expressions as arguments, so a declaration or
    # statement must be wrapped into a block expression in order to be passed
    # in as arguments.
    # This is the form of the if expression:
    # if (expr) expr [else expr] ;
    # The else clause is optional, but if ommitted, will be interpreted as
    # if (expr) expr else () ;
    case nextToken.kind
    when 'val', 'var', 'def', 'class'
      # Manually insert a block node
      p = Node.new(:BLOCK_EXPR)
      p.addChild(declaration)
      n.addChild(p)
    when 'break', 'continue', 'do', ';', 'for', 'print', 'return', 'while'
      # Manually insert a block node
      p = Node.new(:BLOCK_EXPR)
      p.addChild(statement)
      n.addChild(p)
    when 'if', :ID, :NULL, :UNIT, :BOOLEAN, :INTEGER, :FLOAT, :IMAGINARY, '(', '[', '{'
      n.addChild(expression)
    end

    if nextToken.kind == 'else'
      n.addChild(elseClause)
    else
      p = Node.new(:EXPRESSION)
      p.addChild(Node::UNIT_LITERAL)
      n.addChild(p)
    end
    n
  end

  def elseClause ()
    # Needs node implementation
    @logger.debug("elseClause")
    match('else')
    case nextToken.kind
    when 'val', 'var', 'def', 'class'
      # Manually insert a block node
      n = Node.new(:BLOCK_EXPR)
      n.addChild(declaration)
    when 'break', 'continue', 'do', ';', 'for', 'print', 'return', 'while'
      # Manually insert a block node
      n = Node.new(:BLOCK_EXPR)
      n.addChild(statement)
    when 'if', :ID, :NULL, :UNIT, :BOOLEAN, :INTEGER, :FLOAT, :IMAGINARY, '(', '[', '{'
      n = expression
    end
    n
  end

  def nameExpr ()
    @logger.debug("nameExpr")
    n = name
    t = nextToken
    if (t.kind == '(' || t.kind == '[' || t.kind == '.')
      p = nameTail(n)
      n = p
    end
    n
  end

  def nameTail (node)
    @logger.debug("nameTail")
    case nextToken.kind
    when '('
      n = functionCall(node)
    when '['
      # This notation is also used to access other aggregations such as tuples and hashes
      n = arrayAccess(node)
    when '.'
      n = objectAccess(node)
    end
    # What is this for?  Is this for chained expressions like x(1)(2)?
    t = nextToken
    if (t.kind == '(' || t.kind == '[' || t.kind == '.')
      p = nameTail(n)
      n = p
    end
    n
  end

  def functionCall (node)
    @logger.debug("functionCall")
    n = Node.new(:FUNCTION_CALL)
    n.addChild(node)
    match('(')
    # can probably just test for NOT ')'
    if expression? nextToken
      n.addChild(arguments)
    else
      # Add empty arguments list
      n.addChild(Node.new(:ARGUMENTS))
    end
    match(')')
    n
  end

  def expression? (token)
    k = token.kind
    if k == :BOOLEAN   ||
       k == :INTEGER   ||
       k == :FLOAT     ||
       k == :IMAGINARY ||
       k == :STRING    ||
       k == :ID ||
       k == '(' ||
       k == '[' ||
       k == '{' then
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
    # Perhaps this should just be called subscript
    n = Node.new(:ARRAY_ACCESS)
    n.addChild(node)
    match('[')
    n.addChild(expression)
    match(']')
    n
  end

  def objectAccess (node)
    @logger.debug("objectAccess")
    # Perhaps this should just be called access
    n = Node.new(:OBJECT_ACCESS)
    n.addChild(node)
    match('.')
    n.addChild(name)
    n
  end

  def name ()
    @logger.debug("name")
    t = nextToken
    match(:ID)
    n = Node.new(:NAME)
    n.setLine(t.line)
    n.setText(t.text)
    n
  end

  def blockExpr ()
    @logger.debug("blockExpr")
    n = Node.new(:BLOCK_EXPR)
    match('{')
    while nextToken.kind != '}'
      n.addChild(blockElement)
    end
    match('}')
    n
  end

  def blockElement ()
    @logger.debug("blockElement")
    # Not sure class declarations should be valid inside blocks --
    # maybe only inside class bodies (i.e. templates)
    case nextToken.kind
    when 'val', 'var', 'def', 'class'
      declaration
    else
      statement
    end
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

  def lambdaExpr ()
    @logger.debug("lambdaExpr")
    n = Node.new(:LAMBDA_EXPR)
    match('lambda')
    match('(')
    if nextToken.kind == :ID
      n.addChild(parameters)
    else
      # Add empty parameters node
      n.addChild(Node.new(:PARAMETERS))
    end
    match(')')
    match('=>')

    if nextToken.kind == '{'
      n.addChild(blockExpr)
    else
      # Manually insert a block node
      p = Node.new(:BLOCK_EXPR)
      p.addChild(blockElement)
      n.addChild(p)
    end
    n
  end

  # ********** Literals **********

  def literal ()
    @logger.debug("literal")
    case nextToken.kind
    when :NULL then nullLiteral
    when :UNIT then unitLiteral
    when :BOOLEAN then booleanLiteral
    when :INTEGER then integerLiteral
    when :FLOAT then floatLiteral
    when :IMAGINARY then imaginaryLiteral
    when :STRING then stringLiteral
    when '[' then arrayLiteral
    when '{' then hashLiteral
    else
      raise "Parse error in literal()"
    end
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
    match(:UNIT)
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

  def stringLiteral ()
    @logger.debug("stringLiteral")
    n = Node.new(:STRING_LITERAL)
    n.setText(nextToken.text)
    match(:STRING)
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
    n.addChild(expression)
    while nextToken.kind == ','
      consume
      # Check for optional trailing comma
      if nextToken.kind != ']'
        n.addChild(expression)
      end
    end
    n
  end

  def hashLiteral ()
    @logger.debug("hashLiteral")
  end

end #class

