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
      node = @root
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
      # Need to pop and throw away any results
      add(Instruction.new(:POP))
      # Perhaps VM is built on non-functional model to avoid useless pops
      # for functions that return unit
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

    def assignmentExpr (node)
      lhs = node.leftChild
      rhs = node.rightChild
      expr(rhs)
      if lhs.kind == :OBJECT_ACCESS then
        objectSet(lhs)
      else
        add(Instruction.new(:STORE, lhs.text))
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
      add(Instruction.new(:LOAD, node.text))
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

