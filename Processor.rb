class Processor

  def initialize (filename, logger=nil)
    @filename = filename
    @logger = logger

    @exports = nil
  end

  def exports ()
    @exports
  end

  def process ()
    puts "Processing #{@filename + ".co"}..."
  
    # Build input stream
    @logger.info("Building input stream...")
    input = InputStream.new(@filename + ".co")
  
    # Build token stream
    @logger.info("Building token stream...")
    lexer = Lexer.new(input)
    lexer.setLogLevel(Logger::WARN)
    tokens = TokenStream.new(lexer)
    puts lexer.problems.errors
    puts lexer.problems.warnings
  
    # Build AST
    @logger.info("Building abstract syntax tree...")
    parser = Parser.new(tokens)
    parser.setLogLevel(Logger::WARN)
    root = parser.start
    puts parser.problems.errors
    puts parser.problems.warnings
  
    # Build scopes and symbol tables
    # This phase does not generate a new data structure per se.
    # It just annotates the AST with scopes and symbol table data.
    # It does other kinds of misc. analysis as well, including identifying imports
    @logger.info("Building scopes...")
    sb = ScopeBuilder.new(root)
    sb.setLogLevel(Logger::WARN)
    sb.start
    puts sb.problems.errors
    puts sb.problems.warnings
  
    # Process imports before evaluating
    # processImports(sb.imports, logger)
  
    errorCount =
      lexer.problems.errorCount +
      parser.problems.errorCount +
      sb.problems.errorCount
  
    if errorCount == 0 then
      # Evaluate AST
      @logger.info("Evaluating...")
      # Really the entire program is an interpreter, not just this stage
      evaluator = Interpreter.new(root)
      evaluator.setLogLevel(Logger::WARN)
      evaluator.start
    end
    
    @exports = evaluator.globals

    # Generate IR
    # This will be implemented later. It will actually come before evaluation.
    #logger.info("Generating intermediate representation (IR)...")
    #@gen = Generator.new(@root)
    #@gen.setLogLevel(Logger::DEBUG)
    #@chain = @gen.start
  
  end

end