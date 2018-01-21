class FunctionBuilder

  # Function objects might need more work, different one based on number of
  # parameters
  # $Function1, $Function2, etc...

  def initialize ()
    @classObj = TauObject.new($Class, "<class 'Function'>")
  end

  def make (params)
    # What is a function object?
    # Answer that question before proceeding

    # Where does this get used?
    # I think when we create functions, we've created them manually
    # Need to convert them to calls to $Function.make
    TauObject.new($Function, params[0])
  end

  def call ()
    puts "You called a function"
  end

  def classObj ()
    @classObj
  end

  def build ()
    @classObj.setMember('super', $Any)

    # The value held by a function object is either:
    # (a) an AST node, or
    # (b) an array containing paramNames and a handle to a native method
    paramNames = ['x']
    makeFun = TauObject.new($Function, [paramNames, method(:make)])
    @classObj.setMember('make', makeFun)
    
    #@classObj.setMember('make', method(:make))

    @classObj.setMember('call', method(:call))
  end

end