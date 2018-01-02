# This can be an example of writing a native module
# Native modules only need to support variables and functions
# Later will worry about supporting classes

# Might need to require some API module

module Common

  def Common.quicker ()
    # Quick throwaway test -- only suitable for testing
    TauObject.new($Function, $unit)
  end

  def Common.slower ()
    # Attempt to exercise actual API
    # A function object normally contains an AST node, whose children are a list
    # of parameters and a block of code to execute
    # A native function object needs to appear similar
    # The runtime needs to detect that it has encountered a native function
    # and then execute it properly.
    # This can be done by checking to see that the value is a Ruby array instead
    # of a node. If it is a ruby array, then that is a tell-tale sign of a
    # native function. Alternatively, native functions could be totally separate
    # object types. That may be a cleaner approach actually.
    params = ['x', 'y']
    code = lambda { |x, y| x + y }
    struct = [params, code]

    result = TauObject.new($Function, struct)
  end

  def Common.sqrt ()
    params = ['x']
    code = lambda { |x| Math.sqrt(x) }
    struct = [params, code]
    result = TauObject.new($Function, struct)
  end

end

