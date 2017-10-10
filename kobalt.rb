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


def main (filename = nil)
  logger = Logger.new(STDOUT)
  logger.level = Logger::DEBUG

  # Build token stream
  logger.info("Building token stream from input...")
  if filename == nil
    filename = 'input.txt'
  end  
  @is = InputStream.new(filename)
  @lexer = Lexer.new(@is)
  @tokens = TokenStream.new(@lexer)

  # Build AST
  logger.info("Building abstract syntax tree (AST)...")
  @parser = Parser.new(@tokens)
  @parser.setLogLevel(Logger::DEBUG)
  @root = @parser.start

  # Build scopes and symbol tables
  # This phase does not generate a new data structure per se.
  # It just populates the AST with scopes and symbol table data.
  logger.info("Building scopes...")
  #@sb = ScopeBuilder.new(@root)
  #@sb.setLogLevel(Logger::DEBUG)
  #@sb.start

  # Interpret
  logger.info("Commence interpreting...")
  @int = Interpreter.new(@root)
  @int.setLogLevel(Logger::DEBUG)
  @int.start

  # LEFT OFF HERE 20SEP2017
  # Modified scope class to check for existence of symbol before defining it
  # to prevent re-defining an existing variable.

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
