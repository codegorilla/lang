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

    case node.kind
    # FIX: This will always be a root node so the case statement shouldn't be required.
    when :PROGRAM
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
  end

  # Declarations

  def valueDecl (node)
    @logger.debug("valueDecl")
    # Place a variable into the locals table
    identifierNode = node.leftChild
    result = expression(node.rightChild)
    # The runtime 'symbol table' holds names and bindings to objects
    # Where does immutability get enforced?
    @fp.store(identifierNode.text, result)
  end

  def variableDecl (node)
    @logger.debug("variableDecl")
    # Place a variable into the locals table
    identifierNode = node.leftChild
    result = expression(node.rightChild)
    # The runtime 'symbol table' holds names and bindings to objects
    # Rebinding a name to an object is ok
    # Re-declaring a name is NOT ok, but that is something that is looked
    # for during semantic analysis, not at runtime. Runtime doesn't care.
    @fp.store(identifierNode.text, result)
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
    # set the scope to the scope attribute stored in the node
    @scope = node.getAttribute("scope")
    # 21 oct 2017 @ 10:38pm
    # Left off here - had a problem in ScopeBuilder because of missing whileStmt
    # but that is fixed now.  The @scope test below is working!
    if (@scope)
      puts "this is the scope here: "
    else
      puts "what a flop!"
    end

    # Push new frame
    # For blocks, the dynamic and static links are the same
    f = Frame.new(@fp, @fp)
    @fp = f
    for i in 0..node.count-1
      blockElement(node.child(i))
    end
    #pop the frame
    @fp = @fp.dynamicLink
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
        if @fp.load(identifierNode.text) != nil
          @fp.store(identifierNode.text, b)
        else
          @fp.staticLink.store(identifierNode.text, b)
        end
      when '+='
        # Compute id + b
        a = expr(identifierNode)
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        c = classObj.getMember('add').call(a, b)
        if @fp.load(identifierNode.text) != nil
          @fp.store(identifierNode.text, c)
        else
          @fp.staticLink.store(identifierNode.text, c)
        end
      when '-='
        # Compute id - b
        a = expr(identifierNode)
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        c = classObj.getMember('sub').call(a, b)
        if @fp.load(identifierNode.text) != nil
          @fp.store(identifierNode.text, c)
        else
          @fp.staticLink.store(identifierNode.text, c)
        end
      when '*='
        # Compute id * b
        a = expr(identifierNode)
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        c = classObj.getMember('mul').call(a, b)
        if @fp.load(identifierNode.text) != nil
          @fp.store(identifierNode.text, c)
        else
          @fp.staticLink.store(identifierNode.text, c)
        end
      when '/='
        # Compute id / b
        a = expr(identifierNode)
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        c = classObj.getMember('div').call(a, b)
        if @fp.load(identifierNode.text) != nil
          @fp.store(identifierNode.text, c)
        else
          @fp.staticLink.store(identifierNode.text, c)
        end
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
    # Load the name from locals, else search for it by walking static links
    result = @fp.load(node.text)
    if result != nil
      result
    else
      tfp = @fp
      while result == nil
        # add in some logic to throw an exception if not found by the time we
        # reach the global scope
        # if result == nil
        #   TauObject.new($Exception, "NameError: identifier '#{node.text}' is not defined")
        # else
        tfp = tfp.staticLink
        result = tfp.load(node.text)
      end
      result
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

