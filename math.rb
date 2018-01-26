# This can be an example of writing a native module
# Native modules only need to support variables and functions
# Later will worry about supporting classes

# Might need to require some API module

module MathModule

  def MathModule.init ()
    @symbols = {}
    @symbols['atan2'] = TauObject.new($Function, [2, method(:atan2)])
    @symbols['cos']   = TauObject.new($Function, [1, method(:cos)])
    @symbols['log']   = TauObject.new($Function, [1, method(:log)])
    @symbols['log10'] = TauObject.new($Function, [1, method(:log10)])
    @symbols['sin']   = TauObject.new($Function, [1, method(:sin)])
    @symbols['sqrt']  = TauObject.new($Function, [1, method(:sqrt)])
    @symbols['tan']   = TauObject.new($Function, [1, method(:tan)])
  end

  def MathModule.symbols ()
    @symbols
  end

  # The parameters get passed in as cobalt objects and have to be "un-boxed".
  # They need to be re-boxed for passing back to the cobalt evaluator.

  def MathModule.atan2 (params)
    y = params[0].value
    x = params[1].value
    TauObject.new($Float, Math.atan2(y, x))
  end

  def MathModule.cos (params)
    x = params[0].value
    TauObject.new($Float, Math.cos(x))
  end

  def MathModule.log (params)
    x = params[0].value
    TauObject.new($Float, Math.log(x))
  end

  def MathModule.log10 (params)
    x = params[0].value
    TauObject.new($Float, Math.log10(x))
  end

  def MathModule.sin (params)
    x = params[0].value
    TauObject.new($Float, Math.sin(x))
  end

  def MathModule.sqrt (params)
    x = params[0].value
    TauObject.new($Float, Math.sqrt(x))
  end

  def MathModule.tan (params)
    x = params[0].value
    TauObject.new($Float, Math.tan(x))
  end

end

