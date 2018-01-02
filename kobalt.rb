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

  # Global variable store
  # Gobal variables are stored into a table in the top (global) frame of the
  # compilation unit. They really need to be stored in a hash table. This is a
  # first attempt at implementing a global hash table for global variables. An
  # alternative is to allow access to the global frames of external compilation
  # units.  But this may require code modification in a linker phase.
  # An alternative is that all imports will import into a namespace, and
  # access to external names can be via those namespaces. This is similar to
  # python.  For example "import random;" creates an object called "random".
  # Access to its members can be done like so: "var t = random.var1;".
  globalHash = {}

  # Process the specified file
  processFile(filename, globalHash, logger)

  nil
end

def processFile (filename, globalHash, logger)
  puts "Processing #{filename}..."

  # Build input stream
  logger.info("Building input stream...")
  input = InputStream.new(filename)

  # Build token stream
  logger.info("Building token stream...")
  lexer = Lexer.new(input)
  lexer.setLogLevel(Logger::WARN)
  tokens = TokenStream.new(lexer)
  puts lexer.problems.errors
  puts lexer.problems.warnings

  # Build AST
  logger.info("Building abstract syntax tree...")
  parser = Parser.new(tokens)
  parser.setLogLevel(Logger::WARN)
  root = parser.start
  puts parser.problems.errors
  puts parser.problems.warnings

  # Build scopes and symbol tables
  # This phase does not generate a new data structure per se.
  # It just annotates the AST with scopes and symbol table data.
  # It does other kinds of misc. analysis as well, including identifying imports
  logger.info("Building scopes...")
  sb = ScopeBuilder.new(root)
  sb.setLogLevel(Logger::WARN)
  sb.start
  puts sb.problems.errors
  puts sb.problems.warnings

  # Process imports before evaluating
  processImports(sb.imports, globalHash, logger)

  processQuicktest(globalHash)

  errorCount =
    lexer.problems.errorCount +
    parser.problems.errorCount +
    sb.problems.errorCount

  if errorCount == 0 then
    # Evaluate AST
    logger.info("Evaluating...")
    # Really the entire program is an interpreter, not just this stage
    evaluator = Interpreter.new(root, globalHash)
    evaluator.setLogLevel(Logger::WARN)
    evaluator.start
  end

  # Generate IR
  # This will be implemented later. It will actually come before evaluation.
  #logger.info("Generating intermediate representation (IR)...")
  #@gen = Generator.new(@root)
  #@gen.setLogLevel(Logger::DEBUG)
  #@chain = @gen.start

end

def processImports (imports, globalHash, logger)
  # This may be able to be parallelized at some point. If separate compilation
  # can be maintained then there should be no reason why files cannot be
  # processed in parallel.
  # Also, a file with multiple dependents should only have to be processed once.
  imports.each do |i|
    processFile(i, globalHash, logger)
  end
end

def processQuicktest (globalHash)
  require "./quicktest"
  # This needs to make a native function object available in the namespace
  # When you look up a name, it will resolve to the native function object
  # Which should just be a regular function with a native code object inside
  # rather than an AST node.

  # For a quick test, add something to the global namespace
  s = Common.slower
  puts s.value.class
  globalHash['quick'] = s
  globalHash['sqrt'] = Common.sqrt

  # This was a success. The next step is to allow loading of native modules.
  # So an entire module will be written in Ruby (or C later on) and then loaded
  # using a standard 'import' statement.
  # The interpreter will determine that the module is a native module, and will
  # load it properly as a native module instead of a standard .co file.
  # An example of usage is that when the native module is loaded in, it will
  # create some global variables and bind values to them -- most importantly,
  # native functions.
  # The first stab at a native module will be the math module, which will
  # contain some trigonometric and trancendental functions, among others.
end

filename = ARGV[0]

if filename
  main(filename)
else
  main
end

