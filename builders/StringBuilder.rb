class StringBuilder

  def initialize ()
    @String = TauObject.new($Class, "<class 'String'>")
  end

  def make (value)
    TauObject.new($String, value)
  end

  def concat (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $String
        z = x.value + y.value
        TauObject.new($String, z)
      else
        TauObject.new($Exception, "Type error: unsupported types for concat: String and <other>")
      end
    result
  end

  def reverse (params)
    TauObject.new($String, params[0].value.reverse)
  end

  def equ (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $String
        z = x.value == y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for ==: String and <other>")
      end
    result
  end

  def neq (params)
    x = params[0]
    y = params[1]
    result =
    case y.type
      when $String
        z = x.value != y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for !=: String and <other>")
      end
    result
  end

  def gt (x, y)
    result = case y.type
    when $String
      z = x.value > y.value
      # return the singletons not a new value
      if z == true then $true else $false end
    else
      TauObject.new($Exception, "Type error: unsupported operand types for >: String and <other>")
    end
    result
  end

  def lt (x, y)
    result = case y.type
    when $String
      z = x.value < y.value
      # return the singletons not a new value
      if z == true then $true else $false end
    else
      TauObject.new($Exception, "Type error: unsupported operand types for <: String and <other>")
    end
    result
  end

  def ge (x, y)
    result = case y.type
    when $String
      z = x.value >= y.value
      # return the singletons not a new value
      if z == true then $true else $false end
    else
      TauObject.new($Exception, "Type error: unsupported operand types for >=: String and <other>")
    end
    result
  end

  def le (x, y)
    result = case y.type
    when $String
      z = x.value <= y.value
      # return the singletons not a new value
      if z == true then $true else $false end
    else
      TauObject.new($Exception, "Type error: unsupported operand types for <=: String and <other>")
    end
    result
  end

  def add (x, y)
    result = case y.type
    when $String
      z = x.value + y.value
      TauObject.new($String, z)
    else
      TauObject.new($Exception, "Type error: unsupported operand types for +: String and <other>")
    end
    result
  end

  def not (x)
    # Need to think about this
    # Do we follow the python/javascript model or the ruby model?
    result = TauObject.new($Bool, false)
    result
  end

  def toString (params)
    x = params[0]
    # Just return the string
    result = x
  end

  def classObj ()
    @String
  end

  def build ()
    @String.setMember('super', $Any)
    @String.setMember('make', method(:make))
    # add should be :add
    @String.setMember('add', TauObject.new($Function, [2, method(:concat)]))
    @String.setMember('concat', TauObject.new($Function, [2, method(:concat)]))
    @String.setMember('reverse', TauObject.new($Function, [2, method(:reverse)]))
    @String.setMember('equ', TauObject.new($Function, [2, method(:equ)]))
    @String.setMember('neq', TauObject.new($Function, [2, method(:neq)]))
    @String.setMember('gt', method(:gt))
    @String.setMember('lt', method(:lt))
    @String.setMember('ge', method(:ge))
    @String.setMember('le', method(:le))
    @String.setMember('not', method(:not))
    @String.setMember('toString', TauObject.new($Function, [1, method(:toString)]))
  end

end
