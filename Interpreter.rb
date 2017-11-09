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

    # The STRING class represents strings
    sfact = StringFactory.new
    sfact.make

    # The FUNCTION class represents functions
    fnfact = FunctionFactory.new
    fnfact.make

    # Frame pointer
    @fp = nil

    # Scope pointer
    @scope = nil

    @breakFlag = false
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

    # might do away with if statements and just have expressions
    # the empty statement will most likely be optimized away before hitting
    # the interpeter
    node.count.times do |i|
      n = node.child(i)
      case n.kind
        when :VALUE_DECL then valueDecl(n)
        when :VARIABLE_DECL then variableDecl(n)
        when :FUNCTION_DECL then functionDecl(n)
        when :CLASS_DECL then classDecl(n)
        # This probably doesn't need to be here because break is only valid inside of loops
        # Can make sure there are no breaks outside of loops during semantic analysis phase
        when :BREAK_STMT then breakStmt(n)
        when :EMPTY_STMT then ;
        when :EXPRESSION_STMT then expressionStmt(n)
        when :PRINT_STMT then printStmt(n)
        when :RETURN_STMT then returnStmt(n)
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
    # Is there anything to do here? Create a function object and assign it to
    # the proper slot in the currently executing frame
    identifierNode = node.child(0)
    parametersNode = node.child(1)
    index = @scope.lookup(identifierNode.text)
    puts "Index is #{index}."
    @fp.store(index, functionBody(node.child(2)))
  end

  def functionBody (node)
    # Create a function object and return it
    # Later on, lambda expressions will also create function objects
    # But lambda expressions will be expressions, not declarations
    # The value inside a function object should be a block of instructions to
    # execute whenever the function is called, i.e. it needs to be an AST node!
    # In a VM, it would probably be a basic block.
    # It might even need to be more than that, because it needs to take into
    # account parameters as well. For now just assume no parameters.
    result = TauObject.new($Function, node)
  end

  # Theory of operation for functions vs. methods:
  # x = cos # returns function object
  # y = cos(t) # returns result of function call
  # x = Math.cos # attempts to call cos with 0 arguments
  # x = Math.cos(t) # calls cos with 1 argument

  # Statements

  def breakStmt (node)
    @logger.debug("breakStmt")
    # Strategy (not sure if this will work)
    # Only valid inside a blockExpr, and more specifically a loop
    # Set some kind of flag that gets read before proceeding to next blockElement
    # If the flag is set, then "return" from the blockExpr immediately
    # This does seem to work after all!
    @breakFlag = true
  end

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
    # Testing idea of statements evaluating to unit
    $unit
  end

  def returnStmt (node)
    @logger.debug("returnStmt")
    # TODO: Needs implementation
    puts "RETURN STATEMENT NEEDS IMPLEMENTATION"
  end

  def whileStmt (node)
    @logger.debug("whileStmt")
    condition = expression(node.leftChild)
    # Condition could be of any type, need to convert it to a Bool
    # If it is already known to be a Bool, then might be able to optimize
    result = $Bool.getMember('equ').call($true, condition)
    while result.value == true
      breakCheck = blockExpr(node.rightChild)
      # Very ugly, but this is just a test
      if breakCheck == nil then break end
      # Re-evaluate condition
      condition = expression(node.leftChild)
      result = $Bool.getMember('equ').call($true, condition)
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
    when :IF_EXPR
      result = ifExpr(node)
    when :FUNCTION_CALL
      result = functionCall(node)
    when :IDENTIFIER
      result = identifier(node)
    when :BLOCK_EXPR
      result = blockExpr(node)
    when :NULL_LITERAL
      result = nullLiteral(node)
    when :UNIT_LITERAL
      result = unitLiteral(node)
    when :BOOLEAN_LITERAL
      result = booleanLiteral(node)
    when :INTEGER_LITERAL
      result = integerLiteral(node)
    when :FLOAT_LITERAL
      result = floatLiteral(node)
    when :IMAGINARY_LITERAL
      result = imaginaryLiteral(node)
    when :STRING_LITERAL
      result = stringLiteral(node)
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
        while !index && scope.link != nil
          fp = fp.staticLink
          scope = scope.link
          index = scope.lookup(identifierNode.text)
        end
        if index != nil
          result = fp.load(index)
          fp.store(index, b)
        else
          raise "Undefined variable '#{identifierNode.text}'"
        end
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

  def blockExpr (node)
    @logger.debug("blockExpr")
    # Fetch the scope attribute stored in the node
    saveScope = @scope
    @scope = node.getAttribute("scope")
    # Push new frame
    # Pushing and popping frames for blocks seems very inefficient
    # Need to investigate optimizations
    # For blocks, the dynamic and static links are the same
    f = Frame.new(@fp, @fp)
    @fp = f
    for i in 0..node.count-2
      blockElement(node.child(i))
      # Break out early if you see a break flag (this is very ugly)
      if @breakFlag == true then break end
    end

    # Breakflag checking is ugly but this is just a test
    if @breakFlag == false
      # save the result of the last element
      result = blockElement(node.child(node.count-1))
    end

    # pop the frame
    @fp = @fp.dynamicLink
    # restore scope
    @scope = saveScope

    # Yes this is ugly, but this is just a test
    if @breakFlag == true then return nil end

    # Block evaluates to the value of the last exprStmt evaluated
    # If the last element was a declaration or statement (other than exprStmt)
    # then return unit.

    # Can blocks be cleaned up to end in an expression instead of exprStmt?
    "HELLO THIS IS THE RESULT OF A BLOCK!"
    TauObject.new($Int, 200)
    result
  end

  def blockElement (node)
    @logger.debug("blockElement")
    case node.kind
    when :VALUE_DECL then valueDecl(node)
    when :VARIABLE_DECL then variableDecl(node)
    when :FUNCTION_DECL then functionDecl(node)
    when :CLASS_DECL then classDecl(node)
    when :BREAK_STMT then breakStmt(node)
    when :EXPRESSION_STMT then expressionStmt(node)
    when :PRINT_STMT then printStmt(node)
    when :WHILE_STMT then whileStmt(node)
    else
      puts "THERE HAS BEEN A MAJOR ERROR"
      exit
    end
  end

  def ifExpr (node)
    @logger.debug("ifExpr")
    condition = expression(node.child(0))
    # Condition could be of any type, need to convert it to a Bool
    # If it is already known to be a Bool, then might be able to optimize

    result = $Bool.getMember('equ').call($true, condition)
    if result.value == true then
      r = expression(node.child(1))
    else
      r = expression(node.child(2))
    end
    r
  end

  def functionCall (node)
    @logger.debug("functionCall")
    puts "functionCall!"
    # evaluate the left side
    # this should result in a Function object, for which a call can be made
    lhs = expr(node.leftChild)
    # evaluate the right side
    # for now assume argument list is empty
    # The function call should cause a jump to the location of the code
    # followed by a return to here
    jumpNode = lhs.value
    # puts "The value is #{jumpNode}."
    # jump to the location
    result = functionBody1(jumpNode)
    # return here
  end

  def functionBody1 (node)
    @logger.debug("functionBody1")
    # scope, frame, etc.
    # Fetch the scope attribute stored in the node
    # FIX: The scope is currently saved in the function declaration, not body
    # In Parr's book, the function actually has a scope outside of the block
    # that contains code for the function. The function scope holds the
    # parameter locals, while the block holds all other locals.
    saveScope = @scope
    @scope = node.getAttribute("scope")
    # Push new frame
    # For blocks, the dynamic and static links are the same
    # For functions, they are NOT the same, so this needs to be fixed.
    f = Frame.new(@fp, @fp)
    @fp = f

    # Assume there is just an expression
    result = blockExpr(node.child)

    # pop the frame
    @fp = @fp.dynamicLink
    # restore scope
    @scope = saveScope

    result
  end

  def identifier (node)
    @logger.debug("identifier")
    # Look up the index in the current scope and use it to load from local table
    scope = @scope
    fp = @fp
    index = scope.lookup(node.text)
    # Logic to traverse higher scopes
    while !index && scope.link != nil
      scope = scope.link
      # Not sure that the fp needs to always move
      fp = fp.staticLink
      index = scope.lookup(node.text)
    end
    if index != nil
      result = fp.load(index)
      result
    else
      # This needs to print a stack trace for lx, not ruby
      raise "variable '#{node.text}' undefined."
    end
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
    $unit
  end

  def booleanLiteral (node)
    @logger.debug("booleanLiteral")
    if node.text == "true" then $true else $false end
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

  def stringLiteral (node)
    @logger.debug("stringLiteral")
    TauObject.new($String, node.text)
  end

end # class

