# This can be an example of writing a native module
# Native modules only need to support variables and functions
# Later will worry about supporting classes

# Might need to require some API module

module MathModule

  def MathModule.init (globalHash)
    globalHash['atan2'] = MathModule.atan2
    globalHash['cos']   = MathModule.cos
    globalHash['log']   = MathModule.log
    globalHash['log10'] = MathModule.log10
    globalHash['sin']   = MathModule.sin
    globalHash['sqrt']  = MathModule.sqrt
    globalHash['tan']   = MathModule.tan
  end

  # A function object normally contains an AST node, whose children are a list
  # of parameters and a block of code to execute
  # A native function object needs to appear similar
  # The runtime needs to detect that it has encountered a native function
  # and then execute it properly.
  # Native function objects have a different object type than normal function
  # objects.

  # The parameters get passed in as cobalt objects and have to be "un-boxed".
  # They need to be re-boxed for passing back to the cobalt evaluator.

  def MathModule.atan2 ()
    params = ['y', 'x']
    code = lambda do |params|
      y = params[0].value
      x = params[1].value
      TauObject.new($Float, Math.atan2(y, x))
    end
    result = TauObject.new($NativeFunction, [params, code])
  end

  def MathModule.cos ()
    params = ['x']
    code = lambda do |params|
      x = params[0].value
      TauObject.new($Float, Math.cos(x))
    end
    result = TauObject.new($NativeFunction, [params, code])
  end

  def MathModule.log ()
    params = ['x']
    code = lambda do |params|
      x = params[0].value
      TauObject.new($Float, Math.log(x))
    end
    result = TauObject.new($NativeFunction, [params, code])
  end

  def MathModule.log10 ()
    params = ['x']
    code = lambda do |params|
      x = params[0].value
      TauObject.new($Float, Math.log10(x))
    end
    result = TauObject.new($NativeFunction, [params, code])
  end

  def MathModule.sin ()
    params = ['x']
    code = lambda do |params|
      x = params[0].value
      TauObject.new($Float, Math.sin(x))
    end
    result = TauObject.new($NativeFunction, [params, code])
  end

  def MathModule.sqrt ()
    params = ['x']
    code = lambda do |params|
      x = params[0].value
      TauObject.new($Float, Math.sqrt(x))
    end
    result = TauObject.new($NativeFunction, [params, code])
  end

  def MathModule.tan ()
    params = ['x']
    code = lambda do |params|
      x = params[0].value
      TauObject.new($Float, Math.tan(x))
    end
    result = TauObject.new($NativeFunction, [params, code])
  end

end
