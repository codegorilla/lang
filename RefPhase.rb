class RefPhase

  # This pass detects if symbols are referenced without valid declarations.
  # Forward references to functions are permitted, provided they are declared
  # with the 'def x () = {...}' notation, rather than lambda notation.
  # Forward references to values and variables are not permitted.
  
  def initialize (root)
    @root = root

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @logger.info("Initialized scope builder.")

    # Maintain a stack of scopes
    @scope = nil

    @label = 0

    @errors = 0
  end
  
  def setLogLevel (level)
    @logger.level = level
  end

  # Temporary for troubleshooting
  def GET_SCOPE()
    @scope
  end

  def errors ()
    @errors
  end

  def start ()
    @logger.debug("start")
    node = root
    # Create global scope
    @scope = Scope.new
    case node.kind
    when :ROOT
      for i in 0..node.count-1
        n = node.child(i)
        case n.kind
        when :VALUE_DECL
          # Anything that can contain a block can contain a scope
          valueDecl(n)
        when :VARIABLE_DECL
          variableDecl(n)
        when :FUNCTION_DECL
          functionDecl(n)
        when :EXPRESSION_STMT
          expressionStmt(n)
        when :IF_STMT
          ifStmt(n)
        when :RETURN_STMT
          returnStmt(n)
        end
      end
    end
    node.setAttribute("scope", @scope)
  end

  def valueDecl (node)
    @logger.debug("valueDecl")
    # There should be some way to mark this name as not re-assignable
    # But that might be something handled by the compiler, not the runtime
    # Note that names are defined here instead of descending to the name node
    # function because name nodes may appear in non-definition contexts.
    identifierNode = node.leftChild
    name = identifierNode.text
    check = @scope.define(name)
    if !check
      # There is an error due to the same value being declared multiple
      # times within this scope.
      puts "ERROR: Multiple declarations of symbol '#{name}'."
      @errors = 1
    end
    # Need to descend into expression because it may contain a block
    expression(node.rightChild)
  end
  
  def variableDecl (node)
    @logger.debug("variableDecl")
    identifierNode = node.leftChild
    name = identifierNode.text
    check = @scope.define(name)
    if !check
      # There is an error due to the same variable being declared multiple
      # times within this scope.
      puts "ERROR: Multiple declarations of symbol '#{name}'."
      @errors = 1
    end
    # Need to descend into expression because it may contain a block
    expression(node.rightChild)
  end
  
  def functionDecl (node)
    @logger.debug("functionDecl")
    identifierNode = node.child(0)
    @scope.define(identifierNode.text)
    # Push a new scope
    @scope = Scope.new(@scope)
    node.setAttribute("scope", @scope)
    # Pretend there are ZERO parameters for now
    # Parameters are the only thing that will appear in this scope
    # However, this scope will be the parent scope for the enclosed block's scope
    functionBody(node.child(1))
    # Pop the scope
    @scope = @scope.link
  end

  def functionBody (node)
    @logger.debug("functionBody")
    # This will always be a block because if the function consisted of a single
    # statement, then a block node was inserted automatically during the parse.
    block(node.child)
  end

  # Block

  def block (node)
    @logger.debug("block")
    # Push a new scope
    @scope = Scope.new(@scope)
    node.setAttribute("scope", @scope)
    # Right now this only does the first element -- need to loop through all elements
    n = node.child(0)
    blockElement(n)
    # Pop the scope
    @scope = @scope.link
  end

  def blockElement (node)
    @logger.debug("blockElement")
    # This could either be a declaration or a statement
    case node.kind
    when :VALUE_DECL
      # Anything that can contain a block can contain a scope
      valueDecl(node)
    when :VARIABLE_DECL
      variableDecl(node)
    when :EXPRESSION_STMT
      expressionStmt(node)
    when :IF_STMT
      ifStmt(node)
    when :RETURN_STMT
      returnStmt(node)
    end
  end

  # ********** Statements **********

  def expressionStmt (node)
    @logger.debug("expressionStmt")
    expression(node.child)
  end

  def ifStmt (node)
    @logger.debug("ifStmt")
    ifExpr(node.child)
  end

  def returnStmt (node)
    @logger.debug("returnStmt")
    expression(node.child)
  end

  def whileStmt (node)
    @logger.debug("whileStmt")
    expression(node.leftChild)
    n = node.rightChild
    if n.kind == :BLOCK
      block(n)
    else
      blockElement(n)
    end
  end

  # ********** Expressions **********

  def expression (node)
    @logger.debug('expression')
    # This is an "expression root" that only happens at the root of the expression
    expr(node.child)
  end

  def expr (node)
    @logger.debug('expr')
    case node.kind
    when :FUNCTION_CALL
      functionCall(node)
    when :ARRAY_ACCESS
      arrayAccess(node)
    when :OBJECT_ACCESS
      objectAccess(node)
    when :LOGICAL_OR_EXPR
      logicalOrExpr(node)
    when :LOGICAL_AND_EXPR
      logicalAndExpr(node)
    when :BINARY_EXPR
      binaryExpr(node)
    when :IDENTIFIER
      identifier(node)
    when :EXPRESSION
      expression(node)
    end
  end

  def ifExpr (node)
    @logger.debug("ifExpr")
    expression(node.child(0))
    n = node.child(1)
    if n.kind == :BLOCK
      block(n)
    else
      blockElement(n)
    end
    if (node.count == 3)
      # This means there is an else clause
      n = node.child(2)
      if n.kind == :BLOCK
        block(n)
      else
        blockElement(n)
      end
    end
  end

  def functionCall (node)
    lhs = node.leftChild
    rhs = node.rightChild
    expr(lhs)
    arguments(rhs)
    inst = Instruction.new(:CALL)
    inst.setText(rhs.count)
    add(inst)
  end

  def arguments (node)
    for i in 0..node.count-1
      n = node.child(i)
      expression(n)
    end
  end

  def arrayAccess (node)
    lhs = node.leftChild
    rhs = node.rightChild
    # got rid of identifier method because it is not needed for symbol definition?
    identifier(lhs)
    expression(rhs)
    inst = Instruction.new(:SUBSCRIPT)
    add(inst)
  end

  def objectAccess (node)
    lhs = node.leftChild
    rhs = node.rightChild
    identifier(lhs)
    identifier(rhs)
    inst = Instruction.new(:GET)
    add(inst)
  end

  def logicalOrExpr (node)
    # The || operator is equivalent to 'if (a) true else b'
    # Need to fully validate that this works.
    expr(node.leftChild)
    expr(node.rightChild)
  end

  def logicalAndExpr (node)
    # The && operator is equivalent to 'if (a) b else false'
    # Need to fully validate that this works.
    expr(node.leftChild)
    expr(node.rightChild)
  end

  def binaryExpr (node)
    # Binary operation - process children first
    expr(node.leftChild)
    expr(node.rightChild)
  end

  def identifier (node)
  end
  
end #class

