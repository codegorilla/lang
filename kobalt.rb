require './InputStream'
require './Lexer'
require './Token'
require './TokenStream'
require './Parser'
require './Node'
require './SymbolTable'
require './Scope'
require './ScopeBuilder'
require './Frame'
require './TauObject'
require './Interpreter'
require './Generator'
require './Instruction'
require 'pp'
require 'logger'
require './BoolFactory'
require './IntFactory'
require './FloatFactory'
require './StringFactory'
require './ArrayFactory'
require './FunctionFactory'
require './Types'
require './ProblemLogger'

def main (filename = 'test_input.txt')
  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO

  # Build input stream
  logger.info("Building input stream...")
  @input = InputStream.new(filename)

  # Build token stream
  logger.info("Building token stream...")
  @lexer = Lexer.new(@input)
  @lexer.setLogLevel(Logger::WARN)
  @tokens = TokenStream.new(@lexer)
  puts @lexer.problems.errors
  puts @lexer.problems.warnings

  # Build AST
  logger.info("Building abstract syntax tree...")
  @parser = Parser.new(@tokens)
  @parser.setLogLevel(Logger::WARN)
  @root = @parser.start
  puts @parser.problems.errors
  puts @parser.problems.warnings

  # Build scopes and symbol tables
  # This phase does not generate a new data structure per se.
  # It just annotates the AST with scopes and symbol table data.
  logger.info("Building scopes...")
  @sb = ScopeBuilder.new(@root)
  @sb.setLogLevel(Logger::WARN)
  @sb.start
  puts @sb.problems.errors
  puts @sb.problems.warnings

  errorCount =
    @lexer.problems.errorCount +
    @parser.problems.errorCount +
    @sb.problems.errorCount

  # Before we can evaluate this chunk, we need to compile its dependencies and
  # execute them first.
  pp @sb.imports

  # At this point, the resources with many stages can be released and re-used
  # for compilation of dependencies. This may be able to be parallelized at some
  # point
  filename = @sb.imports[0]
  puts filename
  @input = InputStream.new(filename)
  @lexer = Lexer.new(@input)
  @lexer.setLogLevel(Logger::WARN)
  @tokens = TokenStream.new(@lexer)
  @parser = Parser.new(@tokens)
  @root1 = @parser.start
  @sb = ScopeBuilder.new(@root1)
  @sb.setLogLevel(Logger::WARN)
  @sb.start
  
  # Gobal variables are stored into a table in the top (global) frame of the
  # compilation unit. They really need to be stored in a hash table. An
  # alternative is to allow access to the global frames of external compilation
  # units.  But this may require code modification in a linker phase.
  # An alternative is that all imports will import into a namespace, and
  # access to external names can be via those namespaces. This is similar to
  # python.  For example "import random;" creates an object called "random".
  # Access to its members can be done like so: "var t = random.var1;".

  # A temporary test of a global variable table that is accessible across
  # compilation units
  globalHash = {}
  
  @eval = Interpreter.new(@root1, globalHash)
  @eval.setLogLevel(Logger::WARN)
  @eval.start


  if errorCount == 0 then
    # Interpret
    # Eventually, this will be called the evaluation phase
    # Because, really the entire program is an interpreter, not just this stage
    logger.info("Interpreting...")
    @int = Interpreter.new(@root, globalHash)
    @int.setLogLevel(Logger::WARN)
    @int.start
  end

  # Generate IR
  #logger.info("Generating intermediate representation (IR)...")
  #@gen = Generator.new(@root)
  #@gen.setLogLevel(Logger::DEBUG)
  #@chain = @gen.start

  nil
end

def is ()
  @is
end

def tokens ()
  @tokens
end

def root ()
  @root
end

def chain ()
  @chain
end

filename = ARGV[0]

if filename
  main(filename)
else
  main
end

