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

    # Scope pointer
    @scope = nil

    @globalScope = true
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
  
  def nextLabel ()
    @label += 1
  end

  def globalScope? ()
    @scope.kind == :GLOBAL
  end

  def localScope? ()
    @scope.kind == :LOCAL
  end

  def start ()
    @logger.debug("start")
    pushChain
    node = @root
    @scope = node.getAttribute("scope")      

    case node.kind
    when :PROGRAM
      inst = Instruction.new(:BEGIN)
      add(inst)
      for i in 0..node.count-1
        n = node.child(i)
        case n.kind
        when :VALUE_DECL
          valueDecl(n)
        when :VARIABLE_DECL then variableDecl(n)
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
        when :STATEMENT then statement(n)
        end
      end
      # Add HALT instruction at very end
      add(Instruction.new(:HALT))
    end
    node.setAttribute('chain', @chain)
    #pp @chain
    #popChain
    @chain
  end

  def variableDecl (node)
    @logger.debug("variableDecl")
    # Declarations only matter at compile time
    # Delegate to assignmentExpr
    assignmentExpr(node)
  end

  def statement (node)
    @logger.debug("statement")
    n = node.child
    expression(n)
    # Need to discard (pop) result from operand stack
    # But assignments already remove the result from the operand stack
    if n.child.kind != :ASSIGNMENT_EXPR
      add(Instruction.new(:POP))
    end

    # Perhaps VM is built on non-functional model to avoid useless pops
    # for functions that return unit
  end

  def preserveStatement (node)
    @logger.debug("preserveStatement")
    # Do not discard (pop) result from operand stack
    n = node.child
    expression(n)
  end

  def expression (node)
    @logger.debug("expression")
    expr(node.child)
  end

  def expr (node)
    @logger.debug("expr")
    result =
      case node.kind
      when :BREAK_EXPR then breakExpr(node)
      when :PRINT_EXPR then printExpr(node)
      when :RETURN_EXPR then returnExpr(node)
      when :WHILE_EXPR then whileExpr(node)
      when :ASSIGNMENT_EXPR then assignmentExpr(node)
      when :LOGICAL_OR_EXPR then logicalOrExpr(node)
      when :LOGICAL_AND_EXPR then logicalAndExpr(node)
      when :BINARY_EXPR then binaryExpr(node)
      when :UNARY_EXPR then unaryExpr(node)
      when :IF_EXPR then ifExpr(node)
      when :BLOCK_EXPR then blockExpr(node)
      when :FUNCTION_CALL then functionCall(node)
      when :OBJECT_ACCESS then objectAccess(node)
      when :NAME then name(node)
      when :NULL_LITERAL then nullLiteral(node)
      when :UNIT_LITERAL then unitLiteral(node)
      when :BOOLEAN_LITERAL then booleanLiteral(node)
      when :INTEGER_LITERAL then integerLiteral(node)
      when :FLOAT_LITERAL then floatLiteral(node)
      when :EXPRESSION then expression(node)
      else
        puts "generator (expr): Something else!"
      end
    nil
  end

  def breakExpr (node)
    # Jump to nearest exit
    @logger.debug("breakExpr")
    add(Instruction.new(:JUMP, "L#{@exit}"))
  end

  def printExpr (node)
    #puts node.kind
  end

  def returnExpr (node)
    @logger.debug("returnExpr")
    expression(node.child)
    add(Instruction.new(:RET))
  end

  def whileExpr (node)
    @logger.debug("whileExpr")
    entryLabel = nextLabel
    exitLabel = nextLabel
    add(Instruction.new(:LAB, "L#{entryLabel}"))
    entryAddress = @chain.length
    condNode = node.child(0)
    expression(condNode)
    # Reference to BF instruction used for back-patching
    bfInst = Instruction.new(:BF, nil)
    add(bfInst)
    saveExit = @exit
    @exit = exitLabel
    bodyNode = node.child(1)
    expression(bodyNode)
    @exit = saveExit
    add(Instruction.new(:JUMP, entryAddress))
    #exitLabel = nextLabel
    add(Instruction.new(:LAB, "L#{exitLabel}"))
    # Back-patch the BF instruction
    exitAddress = @chain.length
    bfInst.setText(exitAddress)
  end

  def assignmentExpr (node)
    @logger.debug("assignmentExpr")
    lhs = node.leftChild
    rhs = node.rightChild
    expr(rhs)
    if lhs.kind == :OBJECT_ACCESS then
      objectSet(lhs)
    else
      variableStore(lhs)
    end
  end

  def objectSet (node)
    expr(node.leftChild)
    add(Instruction.new(:SET, node.rightChild.text))
  end

  def variableStore (node)
    # Determine if this is global or local scope
    # If global scope then STORE will be used to store into global hash
    # If local scope then STORL will be used to store into an index
    if globalScope? then
      add(Instruction.new(:STORE, node.text))
    else
      # Search all locals tables all the way up to global scope
      found = false
      scope = @scope
      index = scope.lookup(node.text)
      while !index && scope.link != nil do
        scope = scope.link
        index = scope.lookup(node.text)
      end

      if scope.link == nil then
        # We are at global scope
        # Try to find it in global hash
        # Needs work
        add(Instruction.new(:STORE, node.text))
      else
        # We are at local scope
        # It has been located in locals table
        if index != nil then
          add(Instruction.new(:STORL, index.to_s))
        end
      end
    end
  end

  def logicalOrExpr (node)
    @logger.debug("logicalOrExpr")
    # Equivalent to 'if (a) true else b'
    expr(node.leftChild)
    # Reference to BF instruction used for back-patching
    bfInst = Instruction.new(:BF, nil)
    add(bfInst)
    add(Instruction.new(:PUSH_BOOL, "true"))
    # Reference to JUMP instruction used for back-patching
    jumpInst = Instruction.new(:JUMP, nil)
    add(jumpInst)
    label = nextLabel
    add(Instruction.new(:LAB, "L#{label}"))
    # Back-patch the BF instruction
    address = @chain.length
    bfInst.setText(address)
    expr(node.rightChild)
    exitLabel = nextLabel
    add(Instruction.new(:LAB, "L#{exitLabel}"))
    # Back-patch the JUMP instruction
    exitAddress = @chain.length
    jumpInst.setText(exitAddress)
  end

  def logicalAndExpr (node)
    # Equivalent to 'if (a) b else false'
    expr(node.leftChild)
    # Reference to BF instruction used for back-patching
    bfInst = Instruction.new(:BF, nil)
    add(bfInst)
    expr(node.rightChild)
    # Reference to JUMP instruction used for back-patching
    jumpInst = Instruction.new(:JUMP, nil)
    add(jumpInst)
    label = nextLabel
    add(Instruction.new(:LAB, "L#{label}"))
    # Back-patch the BF instruction
    address = @chain.length
    bfInst.setText(address)
    add(Instruction.new(:PUSH_BOOL, "false"))
    exitLabel = nextLabel
    add(Instruction.new(:LAB, "L#{exitLabel}"))
    # Back-patch the JUMP instruction
    exitAddress = @chain.length
    jumpInst.setText(exitAddress)
  end

  def binaryExpr (node)
    expr(node.leftChild)
    expr(node.rightChild)
    opcode =
      case node.text
      when '|' then :OR
      when '^' then :XOR
      when '&' then :AND
      when '==' then :EQU
      when '!=' then :NEQ
      when '>' then :GT
      when '<' then :LT
      when '>=' then :GE
      when '<=' then :LE
      when '>>' then :SHR
      when '<<' then :SHL
      when '+' then :ADD
      when '-' then :SUB
      when '*' then :MUL
      when '/' then :DIV
      end
    add(Instruction.new(opcode))
  end

  def unaryExpr (node)
    expr(node.child)
    opcode =
      case node.text
      when '-' then :NEG
      when '~' then :BNOT
      when '!' then :NOT
      end
    add(Instruction.new(opcode))
  end

  def ifExpr (node)
    @logger.debug("ifExpr")
    condNode = node.child(0)
    expression(condNode)
    # Reference to BF instruction used for back-patching
    bfInst = Instruction.new(:BF, nil)
    add(bfInst)
    bodyNode = node.child(1)
    expression(bodyNode)
    exitLabel = nextLabel
    add(Instruction.new(:LAB, "L#{exitLabel}"))
    # Back-patch the BF instruction
    exitAddress = @chain.length
    bfInst.setText(exitAddress)
  end

  def blockExpr (node)
    # Fetch the scope attribute stored in the node
    saveScope = @scope
    @scope = node.getAttribute("scope")

    # Might do away with blocks
    #add(Instruction.new(:PUSH_BLOCK))
    
      puts "node count is #{node.count}"

    for i in 0..node.count-2 do
      n = node.child(i)
      case n.kind
      when :VARIABLE_DECL then
        puts "vardecl"
        variableDecl(n)
      when :STATEMENT then
        puts "found a stmt"
        statement(n)
      else
        puts "other"
      end
    end

    # Remaining statement is value of the block expression so we dont want to
    # pop it off the operand stack, but re-use it instead
    preserveStatement(node.child(node.count-1))

    # Might do away with blocks
    #add(Instruction.new(:POP_BLOCK))

    # restore scope
    @scope = saveScope

  end

  def functionCall (node)
    callable = node.leftChild
    arguments = node.rightChild
    expr(callable)
    add(Instruction.new(:CALL))
  end

  def objectAccess (node)
    namespace = node.leftChild
    member = node.rightChild
    add(Instruction.new(:LOAD, namespace.text))
    add(Instruction.new(:GET, member.text))
  end

  def name (node)
    if globalScope? then
      add(Instruction.new(:LOAD, node.text))
    else
      # Search all locals tables all the way up to global scope
      found = false
      scope = @scope
      index = scope.lookup(node.text)
      while !index && scope.link != nil do
        scope = scope.link
        index = scope.lookup(node.text)
      end

      if scope.link == nil then
        # We are at global scope
        # Try to find it in global hash
        # Needs work
        add(Instruction.new(:LOAD, node.text))
      else
        # We are at local scope
        # It has been located in locals table
        if index != nil then
          add(Instruction.new(:LOADL, index.to_s))
        end
      end
    end
  end

  def nullLiteral (node)
    add(Instruction.new(:PUSH_NULL))
  end

  def unitLiteral (node)
    add(Instruction.new(:PUSH_UNIT))
  end

  def booleanLiteral (node)
    add(Instruction.new(:PUSH_BOOL, node.text))
  end

  def integerLiteral (node)
    add(Instruction.new(:PUSH_INT, node.text))
  end

  def floatLiteral (node)
    add(Instruction.new(:PUSH_FLOAT, node.text))
  end

end #class

