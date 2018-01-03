# This can be an example of writing a native module
# Native modules only need to support variables and functions
# Later will worry about supporting classes

# Might need to require some API module

module Common

  def Common.add ()
    # Attempt to exercise actual API
    # A function object normally contains an AST node, whose children are a list
    # of parameters and a block of code to execute
    # A native function object needs to appear similar
    # The runtime needs to detect that it has encountered a native function
    # and then execute it properly.
    # Native function objects have a different object type than normal function
    # objects.
    
    # The parameters get passed in as cobalt objects and have to be "un-boxed".
    # They need to be re-boxed for passing back to the cobalt evaluator.
    params = ['x', 'y']
    code = lambda do |params|
      x = params[0].value
      y = params[1].value
      TauObject.new($Float, x + y)
    end
    result = TauObject.new($NativeFunction, [params, code])
  end

  def Common.sqrt ()
    params = ['x']
    code = lambda do |params|
      x = params[0].value
      TauObject.new($Float, Math.sqrt(x))
    end
    result = TauObject.new($NativeFunction, [params, code])
  end

  def Common.sin ()
    params = ['x']
    code = lambda do |params|
      x = params[0].value
      TauObject.new($Float, Math.sin(x))
    end
    result = TauObject.new($NativeFunction, [params, code])
  end

end

