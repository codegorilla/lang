require './InputStream'
require './Lexer'
require './Token'
require './TokenStream'
require './Parser'
require './Node'
require './Generator'
require './Instruction'
require 'pp'
require 'logger'

def main ()
  logger = Logger.new(STDOUT)
  logger.level = Logger::DEBUG

  # Build token stream
  logger.info("Building token stream from input...")
  @is = InputStream.new("input.txt")
  @lexer = Lexer.new(@is)
  @tokens = TokenStream.new(@lexer)

  # Build AST
  logger.info("Building abstract syntax tree (AST)...")
  @parser = Parser.new(@tokens)
  @parser.setLogLevel(Logger::DEBUG)
  @root = @parser.start

  # Generate IR
  logger.info("Generating intermediate representation (IR)...")
  @gen = Generator.new(@root)
  @gen.setLogLevel(Logger::DEBUG)
  @chain = @gen.start

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
