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

    # The ARRAY class represents arrays
    afact = ArrayFactory.new
    afact.make

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

    node.count.times do |i|
      n = node.child(i)
      case n.kind
      when :VALUE_DECL then valueDecl(n)
      when :VARIABLE_DECL then variableDecl(n)
      when :FUNCTION_DECL then functionDecl(n)
      when :OBJECT_DECL then objectDecl(n)
      when :CLASS_DECL then classDecl(n)
      when :STATEMENT then statement(n)
      else
        raise "Runtime error in program()"
      end
    end
  end

  # DECLARATIONS

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
    # (functionDecl identifier [function (params? p1 p2) blockExpr])
    # Create function object and assign it to proper slot in current frame
    identifierNode = node.child(0)
    index = @scope.lookup(identifierNode.text)
    @fp.store(index, function(node.child(1)))
  end

  def function (node)
    @logger.debug("function")
    # Unike a variable declaration or block expression, the function body does
    # not get evaluated when it is seen. A function object is created and bound
    # to the name (or associated slot within a stack frame) at run time. In a
    # function call, this function object will then be called. The function
    # object must have a link to the AST nodes that will be executed. This is
    # its "value", just as an integer might have a value of 1, 2, 3, etc.

    # Parameters don't get processed until function call time
    # At that point arguments would get bound to parameters
    # The names are already in the symbol table, so we might not even need to
    # descend into these nodes during execution time
    #parameters(node.child(1)) 0?

    # Create a function object and return it
    # Later on, lambda expressions will also create function objects
    # The value inside a function object should be an expression to evaluate
    # whenever the function is called, i.e. it needs to be an AST node!
    # In a VM, it would probably be a basic block or superblock.
    result = TauObject.new($Function, node)
  end

  def parameters (node)
    @logger.debug("parameters")
    node.children.each do |n|
      parameter(n)
    end
  end

  def parameter (node)
    @logger.debug("parameter")
    # Each one of these needs to be processed
  end
  
  def objectDecl (node)
    @logger.debug("objectDecl")
    # Create body and assign it to proper slot in current frame
    identifierNode = node.leftChild
    index = @scope.lookup(identifierNode.text)
    @fp.store(index, body(node.rightChild))
  end

  def body (node)
    @logger.debug("body")
    # Create the object
    obj = TauObject.new($Object, '<Object>')

    # One idea is to push a new "scope" here. The problem is that our resolver
    # routine is written assuming scopes follow function frames, not objects
    # so for now don't push this scope, and rely on 'this' pointer instead.
    # Test using scopes again - 10 Dec 2017
    saveScope = @scope
    @scope = node.getAttribute("scope")

    # Set the special 'this' pointer
    # might need a stack of these to permit nesting of object definitions
    @thisPtr = obj

    # Need to diverge from standard declarations because we need to store in
    # the object's hash table rather than frame's table of local variables
    for i in 0..node.count-1 do
      memberDeclaration(node.child(i), obj)
    end

    # Restore previous scope (if it was pushed)
    @scope = saveScope

    result = obj
    result
  end

  def memberDeclaration (node, obj)
    @logger.debug("memberDeclaration")
    # No need to lookup index; store directly by name
    identifierNode = node.leftChild
    name = identifierNode.text
    # Figure out what kind of declaration it is
    value =
      case node.kind
      when :VALUE_DECL then expression(node.rightChild)
      when :VARIABLE_DECL then expression(node.rightChild)
      when :FUNCTION_DECL then function(node.rightChild)
      end
    obj.setMember(name, value)
    nil
  end

  def classDecl (node)
    @logger.debug("classDecl")
    # Create the class object
    identifierNode = node.leftChild
    index = @scope.lookup(identifierNode.text)
    @fp.store(index, template(node.rightChild))
  end

  def template (node)
    @logger.debug("template")
    obj = TauObject.new($Object, '<Class>')
    # For each declaration inside, do something
    # e.g. var x = 1;
    # translatest to obj.x = 1;
    node.children.each do |n|
      memberDecl(n, obj)
    end
    obj
  end

  def memberDecl (node, obj)
    case node.kind
    when :VARIABLE_DECL then
      puts "vardecl"
      identifierNode = node.leftChild
      obj.setMember(identifierNode.text, expression(node.rightChild))
    when :FUNCTION_DECL then
      puts "methoddecl"
    end
  end

  # Theory of operation for functions vs. methods:
  # x = cos # returns function object
  # y = cos(t) # returns result of function call
  # x = Math.cos # attempts to call cos with 0 arguments
  # x = Math.cos(t) # calls cos with 1 argument

  # STATEMENTS

  def statement (node)
    @logger.debug("statement")
    # At global level this should assign to implicit variable 'ans'
    # At local level the result can be thrown away
    # Since the result is thrown away, then optimizer can eliminate the code
    #result = nil
    n = node.child
    #result =
    #case n.kind
    # Break is only valid inside loops
    #when :BREAK_EXPR then breakExpr(n)
    #when :PRINT_EXPR then printExpr(n)
    #when :RETURN_EXPR then returnExpr(n)
    #when :WHILE_EXPR then whileExpr(n)
    #else
    #  expression(n)
    #end
    # statement isn't really supposed to have a result
    result = expression(n)
    result
  end

  # EXRESSIONS

  def expression (node)
    @logger.debug("expression")
    # Root expression nodes only exist at the top of an expression tree
    result = expr(node.child)
    result
  end

  def expr (node)
    @logger.debug("expr")
    result =
      case node.kind
        # Check for breaks outside of loops during semantic analysis phase
        when :BREAK_EXPR then breakExpr(node)
        when :DO_EXPR then doExpr(node)
        when :FOR_EXPR then forExpr(node)
        when :PRINT_EXPR then printExpr(node)
        when :RETURN_EXPR then returnExpr(node)
        when :WHILE_EXPR then whileExpr(node)
        when :ASSIGNMENT_EXPR then assignmentExpr(node)
        when :COMPOUND_ASSIGNMENT_EXPR then compoundAssignmentExpr(node)
        when :BINARY_EXPR then binaryExpr(node)
        when :UNARY_EXPR then unaryExpr(node)
        when :IF_EXPR then ifExpr(node)
        when :FUNCTION_CALL then functionCall(node)
        when :NAME then name(node)
        when :OBJECT_ACCESS then objectAccess(node)
        when :BLOCK_EXPR then blockExpr(node)
        when :LAMBDA_EXPR then lambdaExpr(node)
        when :THIS then thisExpr(node)
        when :NULL_LITERAL then nullLiteral(node)
        when :UNIT_LITERAL then unitLiteral(node)
        when :BOOLEAN_LITERAL then booleanLiteral(node)
        when :INTEGER_LITERAL then integerLiteral(node)
        when :FLOAT_LITERAL then floatLiteral(node)
        when :IMAGINARY_LITERAL then imaginaryLiteral(node)
        when :STRING_LITERAL then stringLiteral(node)
        when :ARRAY_LITERAL then arrayLiteral(node)
        when :EXPRESSION then expression(node)
      else
        puts "interp (expr): Something else!"
      end
    result
  end

  def breakExpr (node)
    @logger.debug("breakExpr")
    # Strategy (not sure if this will work)
    # Only valid inside a blockExpr, and more specifically a loop
    # Set some kind of flag that gets read before proceeding to next blockElement
    # If the flag is set, then "return" from the blockExpr immediately
    # This does seem to work after all!
    @breakFlag = true
    # Break expressions never actually return, they have a type of Nothing
  end

  def doExpr (node)
    @logger.debug("doExpr")
    # Run through loop one time first
    breakCheck = expression(node.leftChild)
    # Very ugly, but this is just a test
    if breakCheck == nil then return $unit end
    # Now check the condition
    condition = expression(node.rightChild)
    # Condition could be of any type, need to convert it to a Bool
    # If it is already known to be a Bool, then might be able to optimize
    result = $Bool.getMember('equ').call($true, condition)
    while result.value == true
      breakCheck = expression(node.leftChild)
      # Very ugly, but this is just a test
      if breakCheck == nil then break end
      # Re-evaluate condition
      condition = expression(node.rightChild)
      result = $Bool.getMember('equ').call($true, condition)
    end
    $unit
  end

  def forExpr (node)
    identifierNode = node.child(0)
    index = @scope.lookup(identifierNode.text)

    startExpr = expression(node.child(1))
    endExpr = expression(node.child(2))
    for i in startExpr.value .. endExpr.value
      # identifier needs to take on value of i
      # create new object out of i each time
      x = TauObject.new($Int, i)
      @fp.store(index, x)
      expression(node.child(3))
    end
    $unit
  end

  def printExpr (node)
    @logger.debug("printExpr")
    resultObj = expression(node.child)
    case resultObj.type
    when $Array then
      count = resultObj.value.count
      x = '['
      for i in 0..(count-2)
        x << resultObj.value[i].value.to_s
        x << ', '
      end
      x << resultObj.value[count-1].value.to_s
      x << ']'
      puts x
    else
      puts resultObj.value
    end
    #puts resultObj.value # "#{result.class}"
    $unit
  end

  def returnExpr (node)
    @logger.debug("returnExpr")
    # TODO: Needs implementation
    puts "RETURN STATEMENT NEEDS IMPLEMENTATION"
  end

  def whileExpr (node)
    @logger.debug("whileExpr")
    condition = expression(node.leftChild)
    # Condition could be of any type, need to convert it to a Bool
    # If it is already known to be a Bool, then might be able to optimize
    result = $Bool.getMember('equ').call($true, condition)
    while result.value == true
      breakCheck = expression(node.rightChild)
      # Very ugly, but this is just a test
      if breakCheck == nil then break end
      # Re-evaluate condition
      condition = expression(node.leftChild)
      result = $Bool.getMember('equ').call($true, condition)
    end
    $unit
  end

  def assignmentExpr(node)
    @logger.debug("assignmentExpr")
    # This works because assignment is right associative
    # Might need to revisit once names become more complex (e.g. x.f[0])

    # If the left node is a name then a store goes directly into a locals or
    # globals table

    # If the left node is a '.' (or something else) then a store equates to a
    # set member operation

    e = expr(node.rightChild)
    n = node.leftChild
    case n.kind
    when :OBJECT_ACCESS then assignObject(n, e)
    when :ARRAY_ACCESS then assignArray(n, e)
    when :NAME then assignName(n, e)
    end
    $unit
  end

  def assignObject (node, e)
    @logger.debug("assignObject")
    n = node.leftChild
    receiver =
      case n.kind
      when :OBJECT_ACCESS then loadObject(n)
      when :NAME then loadName(n)
      end
    receiver.setMember(node.rightChild.text, e)
    nil
  end

  def loadObject (node)
    @logger.debug("loadObject")
    n = node.leftChild
    receiver =
      case n.kind
      when :OBJECT_ACCESS then loadObject(n)
      when :NAME then loadName(n)
      end
    receiver.getMember(node.rightChild.text)
  end

  def loadName (node)
    @logger.debug("loadName")
    # Load name (with intent to possibly store expr into a member or sub-member)
    index = fetchNameIndex(node)
    if index != nil
      result = @fp.load(index)
    else
      raise "Undefined variable '#{node.text}'"
    end
    result
  end

  def assignName (node, e)
    @logger.debug("assignName")
    index = fetchNameIndex(node)
    if index != nil
      @fp.store(index, e)
    else
      raise "Undefined variable '#{node.text}'"
    end
    nil
  end

  def fetchNameIndex (node)
    @logger.debug("fetchNameIndex")
    # need to see if the variable is defined in this block
    # if not, then it is in a higher lexical scope
    # can this be done at compile time?
    fp = @fp
    scope = @scope
    index = scope.lookup(node.text)

    # probably want while scope != global
    while !index && scope.link != nil do
      fp = fp.staticLink
      scope = scope.link
      index = scope.lookup(node.text)
    end
    index
  end

  def compoundAssignmentExpr (node)
    @logger.debug("compoundAssignmentExpr")
    nameNode = node.leftChild
    b = expr(node.rightChild)
    op = node.text

    methodName =
      case op
      when '+=' then 'add'
      when '-=' then 'sub'
      when '*=' then 'mul'
      when '/=' then 'div'
      end

    # Compute t0 = name + b
    a = expr(nameNode)
    classObj = a.type
    if classObj == nil
      # Throw exception
    end

    c = classObj.getMember(methodName).call(a, b)
    fp = @fp
    scope = @scope
    index = scope.lookup(nameNode.text)

    # probably want while scope != global
    #while !index
    if !index
      fp = fp.staticLink
      scope = scope.link
      index = scope.lookup(nameNode.text)
    end
    
    result = fp.load(index)
    fp.store(index, c)

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

    # Block evaluates to the value of the last expression evaluated
    # If the last element was a declaration then return unit.

    # Can blocks be cleaned up to end in an expression instead of exprStmt?
    "HELLO THIS IS THE RESULT OF A BLOCK!"
    TauObject.new($Int, 200)
    result
  end

  def blockElement (node)
    @logger.debug("blockElement")
    result =
    case node.kind
    when :VALUE_DECL then valueDecl(node)
    when :VARIABLE_DECL then variableDecl(node)
    when :FUNCTION_DECL then functionDecl(node)
    when :CLASS_DECL then classDecl(node)
    when :STATEMENT then statement(node)
    else
      puts "THERE HAS BEEN A MAJOR ERROR"
      puts "node kind is #{node.kind}"
      exit
    end
    # Not sure what this result is for
    # Declarations and statements don't have results
    # That said, the result of the last evaluated expression needs to be
    # returned, so maybe that is what this is
    result
  end

  def lambdaExpr (node)
    @logger.debug("lambdaExpr")
    # Isn't this just like a function?
    result = function(node)
    result
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
    # evaluate the left side
    # this should result in a Function object, for which a call can be made
    functionObj = expr(node.leftChild)
    
    # evaluate the right side, e.g. argument list
    # As part of the calling sequence, these arguments must be passed in to
    # function1.
    # At some point need to enforce numArgs == numParams
    # for now don't worry about it
    args = []
    argumentsNode = node.rightChild
    argumentsNode.children.each do |n|
      argObj = expression(n)
      args.push(argObj)
    end

    # The function call should cause a jump to the location of the code
    jumpNode = functionObj.value
    result = function1(jumpNode, args)
    result
  end

  def function1 (node, args)
    @logger.debug("function1")
    # Fetch the scope attribute stored in the node
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

    # bind parameters to arguments
    parametersNode = node.leftChild
    parametersNode.count.times do |i|
      parameterNode = parametersNode.child(i)
      idNode = parameterNode.child
      index = @scope.lookup(idNode.text)
      @fp.store(index, args[i])
    end

    n = node.rightChild
    result =
    case n.kind
    when :EXPRESSION then expression(n)
    when :BLOCK_EXPR then blockExpr(n)
    end
    
    # pop frame and restore scope
    @fp = @fp.dynamicLink
    @scope = saveScope

    result
  end

  def name (node)
    @logger.debug("name")
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
      # This might be a problem: assuming that we are loading a name from a
      # frame. What if we are loading it from an object?
      # Probably need to mark scopes as either procedural or object-based
      # and load based on the result of a check
      if @scope.objectFlag == true then
        result = @thisPtr.getMember(node.text)
      else
        result = fp.load(index)
      end
      result
    else
      # This needs to print a stack trace for lx, not ruby
      raise "variable '#{node.text}' undefined."
    end
  end

  def objectAccess (node)
    @logger.debug("objectAccess")
    # left side is object
    # right side is value stored in object
    # step 1. get the object
    leftNode = node.leftChild
    if leftNode.kind == :THIS then
      # ...from 'this' pointer
      obj = @thisPtr
    elsif leftNode.kind == :OBJECT_ACCESS then
      obj = objectAccess(leftNode)
    elsif leftNode.kind == :NAME then
      # ...out of locals table
      obj = name(node.leftChild)
    else
      raise "THIS CAN'T HAPPEN"
    end
    # step 2. get the name of the member
    memberName = node.rightChild.text
    # step 3. look up the value using the name
    result = obj.getMember(memberName)
    result
  end

  def thisExpr (node)
    @logger.debug("thisExpr")
    # This should always point to the current object
    @thisPtr
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

  def arrayLiteral (node)
    @logger.debug("arrayLiteral")
    # Need to evaluate each element to produce an array of objects
    if node.count == 1
      array = arrayElements(node.child)
    end

    # temporary dummy array
    TauObject.new($Array, array)
  end

  def arrayElements (node)
    @logger.debug("arrayElements")
    array = []
    node.children.each do |n|
      resultObj = expression(n)
      array.push(resultObj)
    end
    array
  end


end # class

