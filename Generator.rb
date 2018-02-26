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
      add(Instruction.new(:POP))
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
        when :PRINT_EXPR then printExpr(node)
        when :WHILE_EXPR then whileExpr(node)
        when :ASSIGNMENT_EXPR then assignmentExpr(node)
        when :BINARY_EXPR then binaryExpr(node)
        when :UNARY_EXPR then unaryExpr(node)
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

    def printExpr (node)
      #puts node.kind
    end

    def whileExpr (node)
      @logger.debug("whileExpr")
      entryLabel = nextLabel
      add(Instruction.new(:LAB, "L#{entryLabel}"))
      entryAddress = @chain.length
      condNode = node.child(0)
      expression(condNode)

      exitLabel = nextLabel
      bfInst = Instruction.new(:BF, nil)
      add(bfInst)
      bodyNode = node.child(1)
      expression(bodyNode)
      #bodyExpr(bodyNode)
      add(Instruction.new(:JUMP, entryAddress))
      add(Instruction.new(:LAB, "L#{exitLabel}"))
      # Need to back-patch the BF instruction
      exitAddress = @chain.length
      bfInst.setText(exitAddress)

      # if bodyNode.kind == :BLOCK
      #   blockExpr(n, entryLabel, exitLabel)
      # else
      #   blockElement(n, entryLabel, exitLabel)
      # end
    end

    def assignmentExpr (node)
      puts "entered assignmentExpr"
      lhs = node.leftChild
      rhs = node.rightChild
      expr(rhs)
      if lhs.kind == :OBJECT_ACCESS then
        objectSet(lhs)
      else
        # Determine if this is global or local scope or block-local scope
        # If global scope then STORE will be used to store into global hash
        # If local scope then STORL will be used to store into an index
        # If block-local scope then STORB will be used to store an index
        if globalScope?
          add(Instruction.new(:STORE, lhs.text))
        else
          # Convert the text into an index
          index = @scope.lookup(lhs.text)
          # If not found in this scope then head to higher scope
          # TODO: Make this go all the way up to global scope!
          if !index then
            hiScope = @scope.link
            index = hiScope.lookup(lhs.text)
          end
          add(Instruction.new(:STORL, index.to_s))
        end
      end
    end

    def objectSet (node)
      expr(node.leftChild)
      add(Instruction.new(:SET, node.rightChild.text))
    end

    def binaryExpr (node)
      expr(node.leftChild)
      expr(node.rightChild)
      opcode =
        case node.text
        when '|' then :BOR
        when '^' then :BXOR
        when '&' then :BAND
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
        index = @scope.lookup(node.text)
        # If not found in this scope then head to higher scope
        # TODO: Make this go all the way up to global scope!
        if !index then
          hiScope = @scope.link
          index = hiScope.lookup(node.text)
        end
        add(Instruction.new(:LOADL, index.to_s))
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

