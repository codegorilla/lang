class Interpreter

  def initialize (root)
    @root = root

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @logger.info("Initialized interpreter.")

    # Define built-in objects

    # The CLASS object is the type of all classes
    @CLASS = TauObject.new

    # The ANY class is the root of the class hierarchy
    # All classes inherit from ANY by default
    # The type of ANY is CLASS
    @ANY = TauObject.new(@CLASS)

    # The INT class represents integers
    @INT = TauObject.new(@CLASS)
    @INT.setMember('super', @ANY)
    @INT.setMember('add', lambda { |x, y| x + y })
    @INT.setMember('sub', lambda { |x, y| x - y })

    # Frame pointer
    @fp = nil
  end

  def setLogLevel (level)
    @logger.level = level
  end

  def start ()
    @logger.debug("start")
    node = root

    # Build first execution frame
    @fp = Frame.new

    case node.kind
    # FIX: This will always be a root node so the case statement shouldn't be required.
    when :ROOT
      for i in 0..node.count-1
        n = node.child(i)
        case n.kind
        when :VALUE_DECL
          valueDecl(n)
        when :VARIABLE_DECL
          variableDecl(n)
        when :FUNCTION_DECL
          #functionDecl(n)
        when :EXPR_STMT
          #exprStmt(n)
        when :IF_STMT
          #ifStmt(n)
        when :RETURN_STMT
          #returnStmt(n)
        end
      end
    end
  end

  def valueDecl (node)
    @logger.debug("valueDecl")
    # Place a variable into the locals table
    nameNode = node.leftChild
    result = expression(node.rightChild)
    puts result.value
    # The runtime 'symbol table' holds names and bindings to objects
    # Where does immutability get enforced?
    @fp.define(nameNode.text, result)
  end

  def variableDecl (node)
    @logger.debug("variableDecl")
    # Place a variable into the locals table
    nameNode = node.leftChild
    result = expression(node.rightChild)
    puts result.value
    # The runtime 'symbol table' holds names and bindings to objects
    @fp.define(nameNode.text, result)
  end

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
    when :BINARY_EXPR
      result = binaryExpr(node)
    when :BOOLEAN_LITERAL
      result = booleanLiteral(node)
    when :INTEGER_LITERAL
      result = integerLiteral(node)
    when :FLOAT_LITERAL
      result = floatLiteral(node)
    when :IMAGINARY_LITERAL
      result = imaginaryLiteral(node)
    else
      puts "Something else!"
    end
    result
  end

  def binaryExpr (node)
    @logger.debug("binaryExpr")
    a = expr(node.leftChild)
    b = expr(node.rightChild)
    op = node.text
    c = case op
      when '+'
        # This assumes an integer, but it can be anything
        # First, need to get the type of a, which will yield a class
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        # Then call the 'add' method stored in the class, passing a and b
        # The add method will check the type of b and perform a type
        # compatibility check, determining the type of the result
        classObj.getMember('add').call(a.value, b.value)
      when '-'
        classObj = a.type
        if classObj == nil
          # Throw exception
        end
        classObj.getMember('sub').call(a.value, b.value)
      when '*'
        a * b
      when '/'
        a / b
    end
    # Assume integer but it could be something else
    result = TauObject.new(@INT, c)
    result
  end

  def unitLiteral (node)
    @logger.debug("unitLiteral")
    TauObject.new('unit')
  end

  def booleanLiteral (node)
    @logger.debug("booleanLiteral")
    TauObject.new('bool', true)
  end

  def integerLiteral (node)
    @logger.debug("integerLiteral")
    TauObject.new(@INT, node.text.to_i)
  end

  def floatLiteral (node)
    @logger.debug("floatLiteral")
    TauObject.new('float64', node.text.to_f)
  end

  def imaginaryLiteral (node)
    @logger.debug("imaginaryLiteral")
    TauObject.new('complex64', node.text.to_f)
  end

end

