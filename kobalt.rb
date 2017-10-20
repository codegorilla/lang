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
require './Types'
require './ProblemLogger'

def main (filename = 'test_input.txt')
  logger = Logger.new(STDOUT)
  logger.level = Logger::WARN

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

  if errorCount == 0 then
    # Interpret
    logger.info("Interpreting...")
    @int = Interpreter.new(@root)
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
