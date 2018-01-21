class NativeFunctionBuilder

  def initialize ()
    @classObj = TauObject.new($Class, "<class 'NativeFunction'>")
  end

  def make (params)
    # Where does this get used?
    # I think when we create functions, we've created them manually
    # Need to convert them to calls to $NativeFunction.make
    TauObject.new($NativeFunction, params[0].value)
  end

  def call ()
    puts "You called a native function"
  end

  def classObj ()
    @classObj
  end

  def build ()
    @classObj.setMember('super', $Any)

    paramNames = ['filename']
    #code = lambda { |params| make(params[0]) }

    makeFun = TauObject.new($NativeFunction, [paramNames, method(:make)])
    @classObj.setMember('make', makeFun)
    
    # NOTE:  The NativeFunction class will not generally be called from the
    # language.  This is because it is not possible to supply native object code
    # from within the language.  So this is something of a special case.
    # Not sure if it makes sense to expose this class at the language level.
    # At some point this class may be merged with the Function class, and the
    # interpreter will check whether the code is native code using a flag.

    # Test making a function
    #makeFun1 = @classObj.getMember('make') # makeFun
    # This is a NativeFunction object with value [params, code]
    # To run this, ...
    # Get the code (a lambda function)
    #code1 = makeFun1.value[1]
    #pp code1
    #x = code1.call([paramNames, code])
    #pp x
    # Call the code with a different value of [params, code]
    # This will produce a new $TauObject

    #@classObj.setMember('make', method(:make))

    params = ['filename']
    code = lambda { |params| call }
    callFun = TauObject.new($NativeFunction, [params, code])
    @classObj.setMember('call', callFun)

    #@classObj.setMember('call', method(:call))
  end

end
