class Generator

  def initialize (root)
    @root = root

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @logger.info("Initialized code generator.")

    @label = 0

    # A list of chains
    @chains = []

    # Each chain is a list of instructions
    @chain = []
  end
  
  def pushChain ()
    @chains.push(@chain)
    @chain = []
  end

  def popChain ()
    @chain = @chains.pop
  end

  def add (instruction)
    @chain.push(instruction)
  end

  def setLogLevel (level)
    @logger.level = level
  end

  def start ()
    @logger.debug("start")
    pushChain
    node = root
    case node.kind
    when :ROOT
      inst = Instruction.new(:BEGIN)
      add(inst)
      for i in 0..node.count-1
        n = node.child(i)
        case n.kind
        when :VALUE_DECL
          valueDecl(n)
        when :VARIABLE_DECL
          variableDecl(n)
        when :FUNCTION_DECL
          functionDecl(n)
        when :EMPTY_STMT
          emptyStmt(n)
        when :EXPR_STMT
          exprStmt(n)
        when :IF_STMT
          ifStmt(n)
        when :RETURN_STMT
          returnStmt(n)
        end
      end
      # Add HALT instruction at very end
      add(Instruction.new(:HALT))
    end
    node.setAttribute('chain', @chain)
    popChain
  end

  def valueDecl (node)
    @logger.debug("valueDecl")
    # First process the expression (RHS)
    # Then store the result into the given name (LHS)
    # There should be some way to mark this name as not re-assignable
    # But that might be something handled by the compiler, not the runtime
    lhs = node.child(0)
    rhs = node.child(1)
    expression(rhs)
    inst = Instruction.new(:STORE)
    inst.setText(lhs.text)
    add(inst)
  end

  def variableDecl (node)
    @logger.debug("variableDecl")
    # First process the expression (RHS)
    # Then store the result into the given name (LHS)
    lhs = node.child(0)
    rhs = node.child(1)
    expression(rhs)
    inst = Instruction.new(:STORE)
    inst.setText(lhs.text)
    add(inst)
  end

  def functionDecl (node)
    @logger.debug("functionDecl")
    # This needs to kick off code generation for a new function
    # LEFT OFF HERE 03 SEP 2017
    #addChain
    # Ignore parameters for now
    n = node.child(1)
    functionBody(n)
  end

  def functionBody (node)
    @logger.debug("functionBody")
    # Save current chain
    pushChain
    n = node.child(0)
    # Ignore statement for now, just worry about blocks
    case n.kind
    when :BLOCK
      block(n)
    end
    node.setAttribute('chain', @chain)
    # Restore saved chain
    popChain
  end

  # Block

  def block (node, entryLabel = nil, exitLabel = nil)
    @logger.debug("block")
    n = node.child(0)
    # Right now this only does the first element -- need to loop through all elements
    blockElement(n, entryLabel, exitLabel)
  end

  def blockElement (node, entryLabel = nil, exitLabel = nil)
    @logger.debug("blockElement")
    # This could either be a declaration or a statement
    n = node
    case n.kind
    when :VALUE_DECL
      valueDecl(n)
    when :VARIABLE_DECL
      variableDecl(n)
    
    when :BREAK_STMT
      breakStmt(n, exitLabel)
    when :CONTINUE_STMT
      continueStmt(n, entryLabel)
    when :EMPTY_STMT
      emptyStmt(n)
    when :EXPR_STMT
      exprStmt(n)
    when :IF_STMT
      ifStmt(n)
    when :RETURN_STMT
      returnStmt(n)
    end
  end

  # ********** Statements **********

  def breakStmt (node, label)
    @logger.debug("breakStmt")
    add(Instruction.new(:JUMP, "L#{label}"))
  end

  def continueStmt (node, label)
    @logger.debug("continueStmt")
    add(Instruction.new(:JUMP, "L#{label}"))
  end

  def emptyStmt (node)
    @logger.debug("emptyStmt")
    # This may need to evaluate to unit - by loading () onto the operand stack
    inst = Instruction.new(:NOP)
    add(inst)
  end

  def exprStmt (node)
    @logger.debug("exprStmt")
    # Basically same as expression, but discards TOP by popping it from the operand stack
    # At global scope this needs to implictly store in the 'ans' variable.
    # At local scope this can just pop the top and discard.
    n = node.child(0)
    expression(n)
    inst = Instruction.new(:POP)
    add(inst)
  end

  # Jump instructions
  # BF [x] = branch if false, x is 16-bit offset
  # BT [x] = branch if true, x is 16-bit offset
  # JUMP [x] = jump relative, x is 16-bit offset
  # JR [x] = jump relative, x is 16-bit offset
  # JA [x] = jump absolute, x is 32-bit absolute
  # JUMP = jump absolute to location in TOS

  def ifStmt (node)
    @logger.debug("ifStmt")
    n = node.child
    ifExpr(n)
    # Do we need to pop TOS?
  end

  def returnStmt (node)
    @logger.debug("returnStmt")
    # Return TOS to caller
    n = node.child
    expression(n)
    add(Instruction.new(:RET))
  end

  def whileStmt (node)
    @logger.debug("whileStmt")
    label = nextLabel
    add(Instruction.new(:LAB, "L#{label}"))
    n = node.child(0)
    expression(n)
    exitLabel = nextLabel
    add(Instruction.new(:BF, "L#{exitLabel}"))
    # do body
    n = node.child(1)
    if n.kind == :BLOCK
      block(n, entryLabel, exitLabel)
    else
      blockElement(n, entryLabel, exitLabel)
    end
    add(Instruction.new(:JUMP, "L#{label}"))
    add(Instruction.new(:LAB, "L#{exitLabel}"))
  end

  # ********** Expressions **********

  def expression (node)
    # This is an "expression root" that only happens at the root of the expression
    n = node.child
    expr(n)
  end

  def expr (node)
    n = node
    case n.kind
    when :FUNCTION_CALL
      functionCall(n)
    when :ARRAY_ACCESS
      arrayAccess(n)
    when :OBJECT_ACCESS
      objectAccess(n)
    when :LOGICAL_OR_EXPR
      logicalOrExpr(n)
    when :LOGICAL_AND_EXPR
      logicalAndExpr(n)
    when :BINARY_EXPR
    # Should assignment leave RHS or () as TOP?
    # RHS is probably more practical. Scala assignment evaluates to ().
      binaryExpr(n)
    when :NAME
      name(n)
    when :UNIT_LITERAL
      unitLiteral(n)
    when :BOOLEAN_LITERAL
      booleanLiteral(n)
    when :INTEGER_LITERAL
      integerLiteral(n)
    when :FLOAT_LITERAL
      floatLiteral(n)
    when :IMAGINARY_LITERAL
      imaginaryLiteral(n)
    when :TUPLE_LITERAL
      tupleLiteral(n)
    when :ARRAY_LITERAL
      arrayLiteral(n)
    when :EXPRESSION
      expression(n)
    end
  end

  def ifExpr (node)
    @logger.debug("ifExpr")
    # Still need to generate labels
    n = node.child(0)
    expression(n)
    label = nextLabel
    add(Instruction.new(:BF, "L#{label}"))
    n = node.child(1)
    if n.kind == :BLOCK
      block(n)
    else
      blockElement(n)
    end
    exitLabel = nextLabel
    add(Instruction.new(:JUMP, "L#{exitLabel}"))
    add(Instruction.new(:LAB, "L#{label}"))
    if (node.count == 3)
      # This means there is an else clause
      n = node.child(2)
      if n.kind == :BLOCK
        block(n)
      else
        blockElement(n)
      end
    end
    add(Instruction.new(:LAB, "L#{exitLabel}"))
  end

  def nextLabel ()
    @label += 1
    @label
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
    name(lhs)
    expression(rhs)
    inst = Instruction.new(:SUBSCRIPT)
    add(inst)
  end

  def objectAccess (node)
    lhs = node.leftChild
    rhs = node.rightChild
    name(lhs)
    name(rhs)
    inst = Instruction.new(:GET)
    add(inst)
  end

  def logicalOrExpr (node)
    # The || operator is equivalent to 'if (a) true else b'
    # Need to fully validate that this works.
    a = node.leftChild
    b = node.rightChild
    expr(a)
    label = nextLabel
    add(Instruction.new(:BF, "L#{label}"))
    add(Instruction.new(:PUSH_T))
    exitLabel = nextLabel
    add(Instruction.new(:JUMP, "L#{exitLabel}"))
    add(Instruction.new(:LAB, "L#{label}"))
    expr(b)
    add(Instruction.new(:LAB, "L#{exitLabel}"))
  end

  def logicalAndExpr (node)
    # The && operator is equivalent to 'if (a) b else false'
    # Need to fully validate that this works.
    a = node.leftChild
    b = node.rightChild
    expr(a)
    label = nextLabel
    add(Instruction.new(:BF, "L#{label}"))
    expr(b)
    exitLabel = nextLabel
    add(Instruction.new(:JUMP, "L#{exitLabel}"))
    add(Instruction.new(:LAB, "L#{label}"))
    add(Instruction.new(:PUSH_F))
    add(Instruction.new(:LAB, "L#{exitLabel}"))
  end

  def binaryExpr (node)
    # Binary operation - process children first
    op = {
      '|' => :OR,
      '^' => :XOR,
      '&' => :AND,
      '==' => :CMP_EQ,
      '!=' => :CMP_NEQ,
      '>' => :CMP_G,
      '>=' => :CMP_GEQ,
      '<' => :CMP_L,
      '<=' => :CMP_LEQ,
      '>>' => :SHR,
      '<<' => :SHL,
      '+' => :ADD,
      '-' => :SUB,
      '*' => :MUL,
      '/' => :DIV,
      '%' => :MOD,
    }
    a = node.leftChild
    b = node.rightChild
    expr(a)
    expr(b)
    # Not sure if a hash lookup is best method
    kind = op[node.text]
    inst = Instruction.new(kind)
    add(inst)
  end

  def name (node)
    inst = Instruction.new(:LOAD)
    inst.setText(node.text)
    add(inst)
  end

  # LD instructions:
  # LDC = load constant
  # LDS = load super
  # LDT = load this

  # PUSH instructions:
  # Used for pushing well known constants
  # PUSH [b] = push signed 8-bit integer b
  # PUSH_0 = push 0
  # PUSH_1 = push 1
  # PUSH_M1 = push -1
  # PUSH_T = push true
  # PUSH_F = push false
  # PUSH_N = push nil
  # PUSH_U = push unit

  def unitLiteral (node)
    inst = Instruction.new(:PUSH_U)
    add(inst)
  end

  def booleanLiteral (node)
    inst = Instruction.new(:LDC)
    inst.setText(node.text)
    add(inst)
  end

  def integerLiteral (node)
    inst = Instruction.new(:LDC)
    inst.setText(node.text)
    add(inst)
  end

  def floatLiteral (node)
    inst = Instruction.new(:LDC)
    inst.setText(node.text)
    add(inst)
  end

  def imaginaryLiteral (node)
    inst = Instruction.new(:LDC)
    inst.setText(node.text)
    add(inst)
  end

  def tupleLiteral (node)
    inst = Instruction.new(:BUILD_TUPLE)
    add(inst)
  end

  def arrayLiteral (node)
    inst = Instruction.new(:BUILD_ARRAY)
    add(inst)
  end

end #class

