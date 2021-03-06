class ScopeBuilder

  def initialize (root)
    @root = root

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN
    @logger.info("Initialized scope builder.")

    @plog = ProblemLogger.new

    # Maintain a stack of scopes
    @scope = nil

    @level = 0

    # Maintain an import dependency list so that we know what compilation units
    # that this particular chunk relies on.
    # This combines with other dependency lists to create a dependency graph
    # For now it is just a list of names, but eventually, need to build a graph
    # data structure.
    @imports = []

    @label = 0
  end
  
  def setLogLevel (level)
    @logger.level = level
  end

  # Temporary for troubleshooting
  def GET_SCOPE()
    @scope
  end

  def imports ()
    @imports
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
    @scope = Scope.new(:GLOBAL)
    for i in 0..node.count-1
      n = node.child(i)
      case n.kind
      when :VALUE_DECL then valueDecl(n)
      when :VARIABLE_DECL then variableDecl(n)
      when :FUNCTION_DECL then functionDecl(n)
      when :OBJECT_DECL then objectDecl(n)
      when :CLASS_DECL then classDecl(n)
      when :STATEMENT then statement(n)
      end
    end
    node.setAttribute("scope", @scope)
    node.setAttribute("imports", @imports)
  end

  # DECLARATIONS

  def declaration (node)
    @logger.debug("declaration")
    case node.kind
    when :VALUE_DECL then valueDecl(node)
    when :VARIABLE_DECL then variableDecl(node)
    when :FUNCTION_DECL then functionDecl(node)
    end
  end

  def valueDecl (node)
    @logger.debug("valueDecl")
    # There should be some way to mark the variable as final
    identifier(node.leftChild)
    expression(node.rightChild)
  end

  def variableDecl (node)
    @logger.debug("variableDecl")
    identifier(node.leftChild)
    expression(node.rightChild)
  end

  def functionDecl (node)
    @logger.debug("functionDecl")
    identifierNode = node.child(0)
    @scope.define(identifierNode.text)
    function(node.child(1))
  end

  def function (node)
    @logger.debug("function")
    # Push a new scope
    @scope = Scope.new(:LOCAL, @level, @scope)
    @level += 1
    # Scope needs to be attached to the function, not the declaration, because
    # the interpreter will jump to the function, not the declaration!
    node.setAttribute("scope", @scope)

    # Parameters are the only thing that will appear in this scope, which is the
    # parent scope for the enclosed block's scope
    parameters(node.child(0))

    # Changed 19NOV2017 - either blockExpr or expression
    if node.child(1).kind == :BLOCK_EXPR
      blockExpr(node.child(1))
    else
      # Might not need to run this path. blockExpr would already be handled.
      expression(node.child(1))
    end

    # Get the current scope's counter
    counter = @scope.counter

    # Pop the scope
    @scope = @scope.link
    @level -= 1

    # Set the restored scope's counter
    @scope.setCounter(counter)
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

  def objectDecl (node)
    @logger.debug("objectDecl")
    identifierNode = node.child(0)
    @scope.define(identifierNode.text)
    body(node.child(1))
  end

  def body (node)
    @logger.debug("body")
    # Push a new scope?
    # If we push a scope, then it will serve as an outer scope for functions
    # but our run-time always tries to load from a locals table, which is a
    # problem. If we don't push a scope, then all members get defined in the
    # parent scope of the object, which is also not what we want.
    @scope = Scope.new(@scope)
    @scope.setObjectFlag(true)
    node.setAttribute("scope", @scope)
    
    # I think this is not required at all for variable and value declarations
    # For function declarations, again, not required, except to link up with
    # outer scopes
    for i in 0..node.count-1
      n = node.child(i)
      declaration(n)
    end
    # Pop the scope
    @scope = @scope.link
  end

  def classDecl (node)
    @logger.debug("classDecl")
    identifierNode = node.child(0)
    @scope.define(identifierNode.text)
    template(node.child(1))
  end

  def template (node)
    @logger.debug("template")
    # It is possible that special declaration methods will be required, but
    # this is fine for now. No scope push is required. See mockup.
    for i in 0..node.count-1
      n = node.child(i)
      declaration(n)
    end
  end

  def identifier (node)
    @logger.debug("identifier")
    name = node.text
    if @scope.lookup(name) == nil
      @scope.define(name)
    else
      # Same variable declared multiple times within scope is error.
      @plog.error("Multiple declarations of symbol '#{name}'.", node.line)
    end
  end

  # STATEMENTS

  def statement (node)
    @logger.debug("statement")
    expression(node.child)
  end

  # EXPRESSIONS

  def expression (node)
    @logger.debug('expression')
    # This is an "expression root" that only happens at the root of the expression
    expr(node.child)
  end

  def expr (node)
    @logger.debug('expr')
    case node.kind
    when :DO_EXPR then doExpr(node)
    when :FOR_EXPR then forExpr(node)
    when :IMPORT_EXPR then importExpr(node)
    when :PRINT_EXPR then printExpr(node)
    when :RETURN_EXPR then returnExpr(node)
    when :WHILE_EXPR then whileExpr(node)
    when :FUNCTION_CALL then functionCall(node)
    when :ARRAY_ACCESS then arrayAccess(node)
    when :OBJECT_ACCESS then objectAccess(node)
    when :LOGICAL_OR_EXPR then logicalOrExpr(node)
    when :LOGICAL_AND_EXPR then logicalAndExpr(node)
    when :BINARY_EXPR then binaryExpr(node)
    when :IF_EXPR then ifExpr(node)
    when :BLOCK_EXPR then blockExpr(node)
    when :LAMBDA_EXPR then lambdaExpr(node)
    when :NAME then name(node)
    when :EXPRESSION then expression(node)
    when :ASSIGNMENT_EXPR then assignmentExpr(node)
    end
  end

  def doExpr (node)
    @logger.debug("doExpr")
    expression(node.rightChild)
    expression(node.leftChild)
  end

  def forExpr (node)
    @logger.debug("forExpr")
    expression(node.child(1))
    expression(node.child(2))
    expression(node.child(3))
  end
  
  def importExpr (node)
    # Will probably do away with this
    # Imports should be processed during execution
    @logger.debug("importExpr")
    importName(node.child)
  end

  def importName (node)
    @logger.debug("importName")
    @imports.push(node.text)
  end

  def printExpr (node)
    @logger.debug("printExpr")
    expression(node.child)
  end

  def returnExpr (node)
    @logger.debug("returnExpr")
    expression(node.child)
  end

  def whileExpr (node)
    @logger.debug("whileExpr")
    expression(node.leftChild)
    expression(node.rightChild)
  end

  def assignmentExpr (node)
    expr(node.leftChild)
    expr(node.rightChild)
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
    @scope = Scope.new(:BLOCK_LOCAL, @level, @scope)
    @level += 1
    node.setAttribute("scope", @scope)
    for i in 0..node.count-1
      n = node.child(i)
      blockElement(n)
    end

    # Get the current scope's counter
    counter = @scope.counter

    # Pop the scope
    @scope = @scope.link
    @level -= 1

    # Set the restored scope's counter
    @scope.setCounter(counter)
  end

  def blockElement (node)
    @logger.debug("blockElement")
    case node.kind
    when :VALUE_DECL then valueDecl(node)
    when :VARIABLE_DECL then variableDecl(node)
    when :STATEMENT then statement(node)
    end
  end

  def lambdaExpr (node)
    @logger.debug("lambdaExpr")
    # Isn't this the same thing as a function?
    function(node)
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
    name(lhs)
    expression(rhs)
    #inst = Instruction.new(:SUBSCRIPT)
    #add(inst)
  end

  def objectAccess (node)
    lhs = node.leftChild
    rhs = node.rightChild
    name(lhs)
    name(rhs)
    #inst = Instruction.new(:GET)
    #add(inst)
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

  def name (node)
    # Might not even be required?
  end

end #class
