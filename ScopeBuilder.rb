class ScopeBuilder

  def initialize (root)
    @root = root

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN
    @logger.info("Initialized scope builder.")

    @plog = ProblemLogger.new

    # Maintain a stack of scopes
    @scope = nil

    @label = 0
  end
  
  def setLogLevel (level)
    @logger.level = level
  end

  # Temporary for troubleshooting
  def GET_SCOPE()
    @scope
  end

  def problems ()
    @plog
  end

  def start ()
    program(@root)
  end

  def program (node)
    @logger.debug("program")
    # Create global scope
    @scope = Scope.new
    for i in 0..node.count-1
      n = node.child(i)
      case n.kind
      when :VALUE_DECL then valueDecl(n)
      when :VARIABLE_DECL then variableDecl(n)
      when :FUNCTION_DECL then functionDecl(n)
      when :EXPRESSION_STMT then expressionStmt(n)
      when :PRINT_STMT then printStmt(n)
      when :RETURN_STMT then returnStmt(n)
      when :WHILE_STMT then whileStmt(n)
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
    if @scope.lookup(name) == nil
      @scope.define(name)
    else
      # Same variable declared multiple times within scope is error.
      @plog.error("Multiple declarations of symbol '#{name}'.", identifierNode.line)
    end
    # Need to descend into expression because it may contain a block
    expression(node.rightChild)
  end
  
  def variableDecl (node)
    @logger.debug("variableDecl")
    identifierNode = node.leftChild
    name = identifierNode.text
    if @scope.lookup(name) == nil
      @scope.define(name)
    else
      # Same variable declared multiple times within scope is error.
      @plog.error("Multiple declarations of symbol '#{name}'.", identifierNode.line)
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
    # Parameters are the only thing that will appear in this scope
    # This scope will be the parent scope for the enclosed block's scope
    parameters(node.child(1))

    # I think the scope needs to be attached to the function body, or "lambda"
    # Not at the declaration, because the interpreter will jump to the lambda,
    # not the declaration!
    # This can be handled by passing the scope into the functionBody, or by
    # setting the annotation from up here. If the functionBody tried to create
    # the scope then it would have to reach back to the declaration in order to
    # get parameters, but there is no parent link in the AST design.
    node.child(2).setAttribute("scope", @scope)


    functionBody(node.child(2))
    # Pop the scope
    @scope = @scope.link
  end

  def parameters (node)
    @logger.debug("parameters")
    node.children.each do |n|
      parameter(n)
    end
  end

  def parameter (node)
    @logger.debug("parameter")
    identifierNode = node.child
    # no need to look it up first, unless to detect if someone does
    #def f (x, x)...
    @scope.define(identifierNode.text)
  end

  def functionBody (node)
    @logger.debug("functionBody")
    # This will always be a block because if the function consisted of a single
    # statement, then a block node was inserted automatically during the parse.
    blockExpr(node.child)
  end

  # ********** Statements **********

  def expressionStmt (node)
    @logger.debug("expressionStmt")
    expression(node.child)
  end

  def printStmt (node)
    @logger.debug("printStmt")
    expression(node.child)
  end

  def returnStmt (node)
    @logger.debug("returnStmt")
    expression(node.child)
  end

  def whileStmt (node)
    @logger.debug("whileStmt")
    expression(node.leftChild)
    n = node.rightChild
    # This should always be a block, so we should be able to
    # get rid of the if-statement
    if n.kind == :BLOCK_EXPR
      blockExpr(n)
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
    when :FUNCTION_CALL then functionCall(node)
    when :ARRAY_ACCESS then arrayAccess(node)
    when :OBJECT_ACCESS then objectAccess(node)
    when :LOGICAL_OR_EXPR then logicalOrExpr(node)
    when :LOGICAL_AND_EXPR then logicalAndExpr(node)
    when :BINARY_EXPR then binaryExpr(node)
    when :IF_EXPR then ifExpr(node)
    when :BLOCK_EXPR then blockExpr(node)
    when :IDENTIFIER then identifier(node)
    when :EXPRESSION then expression(node)
    end
  end

  def ifExpr (node)
    @logger.debug("ifExpr")
    expression(node.child(0))
    expression(node.child(1))
    if node.count == 3
      expression(node.child(2))
    end
  end

  def blockExpr (node)
    @logger.debug("blockExpr")
    # Push a new scope
    @scope = Scope.new(@scope)
    node.setAttribute("scope", @scope)
    for i in 0..node.count-1
      n = node.child(i)
      blockElement(n)
    end
    # Pop the scope
    @scope = @scope.link
  end

  def blockElement (node)
    @logger.debug("blockElement")
    case node.kind
    when :VALUE_DECL then valueDecl(node)
    when :VARIABLE_DECL then variableDecl(node)
    when :EXPRESSION_STMT then expressionStmt(node)
    when :IF_STMT then ifStmt(node)
    when :RETURN_STMT then returnStmt(node)
    end
  end

  def functionCall (node)
    @logger.debug("functionCall")
    expr(node.leftChild)
    arguments(node.rightChild)
  end

  def arguments (node)
    @logger.debug("arguments")
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

