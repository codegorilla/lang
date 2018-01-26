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
require './ProblemLogger'
require './Processor'

require './builders/ClassBuilder'
require './builders/AnyBuilder'
require './builders/NullBuilder'
require './builders/UnitBuilder'
require './builders/ExceptionBuilder'
require './builders/BoolBuilder'
require './builders/IntBuilder'
require './builders/FloatBuilder'
require './builders/StringBuilder'
require './builders/ArrayBuilder'
require './builders/FunctionBuilder'
require './builders/NativeFunctionBuilder'
require './builders/NamespaceBuilder'

require 'pp'
require 'logger'

def main (filename = 'test_input')
  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO

  # Registry is a global registry for top-level classes and modules
  # It ensures that top-level classes and modules don't get rebuilt if they are
  # imported multiple times.
  $Registry = {}

  # Define and register built-in objects
  # Registrations occur only for top-level things
  # This way they don't get rebuilt when something is imported twice

  # The $Class object is the type of all classes
  cb = ClassBuilder.new
  $Registry['Class'] = cb.classObj
  $Class = cb.classObj

  # The $Any class is the root of the class hierarchy
  # All classes inherit from $Any by default
  ab = AnyBuilder.new
  $Registry['Any'] = ab.classObj
  $Any = ab.classObj
  
  nb = NullBuilder.new
  $Registry['Null'] = nb.classObj
  $Null = nb.classObj
  $null = nb.get_null

  ub = UnitBuilder.new
  $Registry['Unit'] = ub.classObj
  $Unit = ub.classObj
  $unit = ub.get_unit

  eb = ExceptionBuilder.new
  $Registry['Exception'] = eb.classObj
  $Exception = eb.classObj

  bb = BoolBuilder.new
  $Registry['Bool'] = bb.classObj
  $Bool = bb.classObj
  $true = bb.get_true
  $false = bb.get_false

  ib = IntBuilder.new
  $Registry['Int'] = ib.classObj
  $Int = ib.classObj

  fb = FloatBuilder.new
  $Registry['Float'] = fb.classObj
  $Float = fb.classObj

  sb = StringBuilder.new
  $Registry['String'] = sb.classObj
  $String = sb.classObj

  rb = ArrayBuilder.new
  $Registry['Array'] = rb.classObj
  $Array = rb.classObj

  fnb = FunctionBuilder.new
  $Registry['Function'] = fnb.classObj
  $Function = fnb.classObj

  nfnb = NativeFunctionBuilder.new
  $Registry['NativeFunction'] = nfnb.classObj
  $NativeFunction = nfnb.classObj

  nsb = NamespaceBuilder.new
  $Registry['Namespace'] = nsb.classObj
  $Namespace = nsb.classObj

  # We needed to make the objects above so that the following methods can
  # reference them while building out their attributes and methods
  cb.build
  ab.build
  nb.build
  ub.build
  eb.build
  bb.build
  ib.build
  fb.build
  sb.build
  rb.build
  fnb.build
  nfnb.build
  nsb.build


  # Built-in objects
  # These should be placed into an outer 'builtins' scope
  $builtins = {}
  $builtins['Class'] = $Registry['Class']
  $builtins['Any'] = $Registry['Any']
  $builtins['Null'] = $Registry['Null']
  $builtins['Unit'] = $Registry['Unit']
  $builtins['Exception'] = $Registry['Exception']
  $builtins['Bool'] = $Registry['Bool']
  $builtins['Int'] = $Registry['Int']
  $builtins['Float'] = $Registry['Float']
  $builtins['String'] = $Registry['String']
  $builtins['Array'] = $Registry['Array']
  $builtins['Function'] = $Registry['Function']
  $builtins['NativeFunction'] = $Registry['NativeFunction']
  $builtins['Namespace'] = $Registry['Namespace']

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

  # Question:  Frames don't exist until runtime.  Is that another reason for the
  # global hash?

  # Need to get rid of the global hash. Compilation units need to have their own
  # globals
  #globalHash = {}

  # Importing native modules...
  # This needs to make a native function object available in the namespace
  # When you look up a name, it will resolve to the native function object
  # Which should just be a regular function with a native code object inside
  # rather than an AST node.

  # This was a success. The next step is to allow loading of native modules.
  # So an entire module will be written in Ruby (or C later on) and then loaded
  # using a standard 'import' statement.
  # The interpreter will determine that the module is a native module, and will
  # load it properly as a native module instead of a standard .co file.
  # An example of usage is that when the native module is loaded in, it will
  # create some global variables and bind values to them -- most importantly,
  # native functions.
  # The first stab at a native module will be the math module, which will
  # contain some trigonometric and transcendental functions, among others.

  # Quick test - set up the loadlib facility.
  # Native function for loading ruby libraries



  def native_loadlib (params)
    filename = params[0].value
    moduleName = params[1].value
    require filename
    classRef = Kernel.const_get(moduleName)
    classRef.init()
    # Create a namespace and put all symbols into it
    # Goal is for native_loadlib to load symbols into the current namespace.
    # But this is not possible right now because it doesn't have a reference
    # to the current namespace. A solution needs to be investigated.
    sym = classRef.symbols
    ns = TauObject.new($Namespace, "<namespace>")
    sym.each do |i|
      name = i[0]
      value = i[1]
      ns.setMember(name, value)
    end
    ns
  end

  loadlib = TauObject.new($Function, [2, method(:native_loadlib)])
  $builtins['loadlib'] = loadlib


  # # Quick test - function to create objects
  # params = []
  # code = lambda do |params|
  #   # Ignore params
  #   TauObject.new()
  # end
  # mkObject = TauObject.new($NativeFunction, [params, code])
  # globalHash['mkObject'] = mkObject

  # # Quick test - function to create classes
  # params = []
  # code = lambda do |params|
  #   # Ignore params
  #   TauObject.new($Class)
  # end
  # mkClass = TauObject.new($NativeFunction, [params, code])
  # globalHash['mkClass'] = mkClass
  
  # This is where some built-ins need to go
  # It is important that they be created one time only
  # and then injected into the interpreter once
  # Otherwise certan objects will have multiple identities (multiple versions)

  # This raises an important question. When a compilation unit is loaded, it has
  # to be registered.  When a different unit attempts to load a unit that has
  # already been loaded, the system simply hands it the unit that was already
  # loaded and registered. This avoids multiple identities.

  # Process the specified file
  p = Processor.new(filename, logger)
  p.process

  nil
end

filename = ARGV[0]

if filename
  main(filename)
else
  main
end

