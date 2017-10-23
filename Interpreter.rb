class Interpreter

  def initialize (root)
    @root = root

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN
    @logger.info("Initialized interpreter.")

    # Define built-in objects

    # The CLASS object is the type of all classes
    @CLASS = TauObject.new

    # The ANY class is the root of the class hierarchy
    # All classes inherit from ANY by default
    # The type of ANY is CLASS
    @ANY = TauObject.new(@CLASS)

    @EXCEPTION = TauObject.new(@CLASS)
    @EXCEPTION.setMember('super', @ANY)

    # The BOOL class represents booleans
    bfact = BoolFactory.new
    bfact.make

    # The INT class represents integers
    ifact = IntFactory.new
    ifact.make
    
    # The FLOAT class represents floating point numbers
    ffact = FloatFactory.new
    ffact.make

    # Frame pointer
    @fp = nil

    # Scope pointer
    @scope = nil
  end

  def setLogLevel (level)
    @logger.level = level
  end

  def start ()
    program(@root)
  end

  def program (node)
    @logger.debug("program")
    # Build first execution frame
    @fp = Frame.new

    # Fetch the global scope
    # Not sure if this will really be the global scope or if it is in some kind
    # of module namespace
    @scope = node.getAttribute("scope")

    if (node.kind != :PROGRAM)
      # This should *always* be a program node so throw exception if it is not
    end

    for i in 0..node.count-1
      n = node.child(i)
      case n.kind
      when :VALUE_DECL then valueDecl(n)
      when :VARIABLE_DECL then variableDecl(n)
      when :FUNCTION_DECL then functionDecl(n)
      when :CLASS_DECL then classDecl(n)
      when :EXPRESSION_STMT then expressionStmt(n)
      when :IF_STMT
        # ifStmt(n)
      when :PRINT_STMT then printStmt(n)
      when :RETURN_STMT
        #returnStmt(n)
      when :WHILE_STMT then whileStmt(n)
      else
        puts "THERE HAS BEEN A MAJOR ERROR"
        exit
      end
    end
  end

  # Declarations

  def valueDecl (node)
    @logger.debug("valueDecl")
    # Note: Where does immutability of vals get enforced?
    # Is that a compile-time or runtime check?
    identifierNode = node.leftChild
    index = @scope.lookup(identifierNode.text)
    @fp.store(index, expression(node.rightChild))
  end

  def variableDecl (node)
    @logger.debug("variableDecl")
    # Store the expression result into the locals table
    identifierNode = node.leftChild
    index = @scope.lookup(identifierNode.text)
    @fp.store(index, expression(node.rightChild))
  end

  def functionDecl (node)
    @logger.debug("functionDecl")
    # fun
    #   identifier
    #   params?
    #     param1
    #     param2
    #   body
    #     block
    identifierNode = node.firstChild
  end

  # Theory of operation for functions vs. methods:
  # x = cos # returns function object
  # y = cos(t) # returns result of function call
  # x = Math.cos # attempts to call cos with 0 arguments
  # x = Math.cos(t) # calls cos with 1 argument

  # Statements

  def expressionStmt (node)
    @logger.debug("expressionStmt")
    # At global level this should assign to implicit variable 'ans'
    # At local level the result can be thrown away
    # Since the result is thrown away, then optimizer can eliminate the code
    result = expression(node.child)
  end

  def printStmt (node)
    @logger.debug("printStmt")
    result = expression(node.child)
    puts result.value
  end

  def whileStmt (node)
    @logger.debug("whileStmt")
    condition = expression(node.leftChild)
    # Condition could be of any type, need to convert it to a Bool
    # If it is already known to be a Bool, then might be able to optimize
    result = $Bool.getMember('equ').call($true, condition)
    while result.value == true
      blockExpr(node.rightChild)
      # Re-evaluate condition
      condition = expression(node.leftChild)
      result = $Bool.getMember('equ').call($true, condition)
    end
  end

  # moves to expression area?
  # NEED TO PUSH A NEW FRAME AND THEN POP IT WHEN DONE
  # That seems inefficient to do on every loop iteration
  # Need to investigate optimizations
  def blockExpr (node)
    @logger.debug("blockExpr")
    # Fetch the scope attribute stored in the node
    saveScope = @scope
    @scope = node.getAttribute("scope")
    # Push new frame
    # For blocks, the dynamic and static links are the same
    f = Frame.new(@fp, @fp)
    @fp = f
    for i in 0..node.count-1
      blockElement(node.child(i))
    end
    # pop the frame
    @fp = @fp.dynamicLink
    # restore scope
    @scope = saveScope
  end

  # Belongs under expressions under blockExpr?
  def blockElement (node)
    @logger.debug("blockElement")
    case node.kind
    when :VALUE_DECL then valueDecl(node)
    when :VARIABLE_DECL then variableDecl(node)
    when :FUNCTION_DECL then functionDecl(node)
    when :CLASS_DECL then classDecl(node)
    when :EXPRESSION_STMT then expressionStmt(node)
    when :PRINT_STMT then printStmt(node)
    when :WHILE_STMT then whileStmt(node)
    else
      puts "THERE HAS BEEN A MAJOR ERROR"
      exit
    end
  end

  # Expressions

  def expression (node)
    @logger.debug("expression")
    # Root expression nodes only exist at the top of an expression tree
    result = expr(node.child)
    result
  end

  def expr (node)
    @logger.debug("expr")
    result = nil
    case node.kind
    when :ASSIGNMENT_EXPR
      result = assignmentExpr(node)
    when :BINARY_EXPR
      result = binaryExpr(node)
    when :UNARY_EXPR
      result = unaryExpr(node)
    when :IDENTIFIER
      result = identifier(node)
    when :NULL_LITERAL
      result = nullLiteral(node)
    when :BOOLEAN_LITERAL
      result = booleanLiteral(node)
    when :INTEGER_LITERAL
      result = integerLiteral(node)
    when :FLOAT_LITERAL
      result = floatLiteral(node)
    when :IMAGINARY_LITERAL
      result = imaginaryLiteral(node)
    when :EXPRESSION
      result = expression(node)
    else
      puts "Something else!"
    end
    result
  end

  def assignmentExpr(node)
    @logger.debug("assignmentExpr")
    # This works because assignment is right associative
    # Might need to revisit once names become more complex (e.g. x.f[0])
    identifierNode = node.leftChild
    b = expr(node.rightChild)
    op = node.text
    d = case op
      when '='
        # need to see if the variable is defined in this block
        # if not, then it is in a higher lexical scope
        # can this be done at compile time?
        fp = @fp
        scope = @scope
        index = scope.lookup(identifierNode.text)
    
        # probably want while scope != global
        #while !index
        if !index
          fp = fp.staticLink
          scope = scope.link
          index = scope.lookup(identifierNode.text)
        end
        result = fp.load(index)
        fp.store(index, b)
      when '+='
        # Compute id + b
        a = expr(identifierNode)
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        c = classObj.getMember('add').call(a, b)
        fp = @fp
        scope = @scope
        index = scope.lookup(identifierNode.text)
    
        # probably want while scope != global
        #while !index
        if !index
          fp = fp.staticLink
          scope = scope.link
          index = scope.lookup(identifierNode.text)
        end
        result = fp.load(index)
        fp.store(index, c)
      when '-='
        # Compute id - b
        a = expr(identifierNode)
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        c = classObj.getMember('sub').call(a, b)
        fp = @fp
        scope = @scope
        index = scope.lookup(identifierNode.text)
    
        # probably want while scope != global
        #while !index
        if !index
          fp = fp.staticLink
          scope = scope.link
          index = scope.lookup(identifierNode.text)
        end
        result = fp.load(index)
        fp.store(index, c)
      when '*='
        # Compute id * b
        a = expr(identifierNode)
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        c = classObj.getMember('mul').call(a, b)
        fp = @fp
        scope = @scope
        index = scope.lookup(identifierNode.text)
    
        # probably want while scope != global
        #while !index
        if !index
          fp = fp.staticLink
          scope = scope.link
          index = scope.lookup(identifierNode.text)
        end
        result = fp.load(index)
        fp.store(index, c)
      when '/='
        # Compute id / b
        a = expr(identifierNode)
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        c = classObj.getMember('div').call(a, b)
        fp = @fp
        scope = @scope
        index = scope.lookup(identifierNode.text)
    
        # probably want while scope != global
        #while !index
        if !index
          fp = fp.staticLink
          scope = scope.link
          index = scope.lookup(identifierNode.text)
        end
        result = fp.load(index)
        fp.store(index, c)
    end
    result = d
    result
  end

  def binaryExpr (node)
    @logger.debug("binaryExpr")
    a = expr(node.leftChild)
    b = expr(node.rightChild)
    op = node.text
    c = case op
      when '|'
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('bor').call(a, b)
      when '^'
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('bxor').call(a, b)
      when '&'
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('band').call(a, b)
      when '=='
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('equ').call(a, b)
      when '!='
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('neq').call(a, b)
      when '>'
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('gt').call(a, b)
      when '<'
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('lt').call(a, b)
      when '>='
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('ge').call(a, b)
      when '<='
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('le').call(a, b)
      when '<<'
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('shl').call(a, b)
      when '>>'
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('shr').call(a, b)
      when '+'
        # First, need to get the type of a, which will yield a class
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        # Then call the 'add' method stored in the class, passing a and b
        # The add method will check the type of b and perform a type
        # compatibility check, determining the type of the result
        classObj.getMember('add').call(a, b)
      when '-'
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('sub').call(a, b)
      when '*'
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('mul').call(a, b)
      when '/'
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('div').call(a, b)
    end
    result = c
    result
  end

  def unaryExpr (node)
    @logger.debug("unaryExpr")
    a = expr(node.child)
    op = node.text
    b = case op
      when '-'
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('uminus').call(a)
      when '~'
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('bnot').call(a)
      when '!'
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('not').call(a)        
    end
  end

  def identifier (node)
    @logger.debug("identifier")
    # Look up the index in the current scope and use it to load from local table
    fp = @fp
    scope = @scope
    index = scope.lookup(node.text)

    #while !index
    if !index
      fp = fp.staticLink
      scope = scope.link
      index = scope.lookup(node.text)
    end
    result = fp.load(index)
    result
  end

  # ********** Literals **********

  def nullLiteral (node)
    @logger.debug("nullLiteral")
    # Should this have a value?
    # Is it just there so something will print?
    TauObject.new($Null, "null")
  end

  def unitLiteral (node)
    @logger.debug("unitLiteral")
    TauObject.new('unit')
  end

  def booleanLiteral (node)
    @logger.debug("booleanLiteral")
    t = node.text
    if t == "true"
      $true
    elsif t == "false"
      $false
    end
  end

  def integerLiteral (node)
    @logger.debug("integerLiteral")
    TauObject.new($Int, node.text.to_i)
  end

  def floatLiteral (node)
    @logger.debug("floatLiteral")
    TauObject.new($Float, node.text.to_f)
  end

  def imaginaryLiteral (node)
    @logger.debug("imaginaryLiteral")
    TauObject.new(@COMPLEX, [0.0, node.text.to_f])
  end

end

