class IntBuilder

  def initialize ()
    @classObj = TauObject.new($Class, "<class 'Int'>")
  end

  # def make (value)
  #   TauObject.new($Int, value)
  # end

  def make (params)
    TauObject.new($Int, params[0].value)
  end

  def bor (x, y)
    result = case y.type
    when $Int
      z = x.value | y.value
      TauObject.new($Int, z)
    when $Float
      TauObject.new($Exception, "Type error: unsupported operand types for |: Int and Float")
    when $Bool
      # Should Bool get promoted to Int in bitwise operations?
      TauObject.new($Exception, "Type error: unsupported operand types for |: Int and Bool")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for |: Int and <other>")
    end
    result
  end

  def bxor (x, y)
    result = case y.type
    when $Int
      z = x.value ^ y.value
      TauObject.new($Int, z)
    when $Float
      TauObject.new($Exception, "Type error: unsupported operand types for ^: Int and Float")
    when $Bool
      TauObject.new($Exception, "Type error: unsupported operand types for ^: Int and Bool")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for ^: Int and <other>")
    end
    result
  end

  def band (x, y)
    result = case y.type
    when $Int
      z = x.value & y.value
      TauObject.new($Int, z)
    when $Float
      TauObject.new($Exception, "Type error: unsupported operand types for &: Int and Float")
    when $Bool
      TauObject.new($Exception, "Type error: unsupported operand types for &: Int and Bool")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for &: Int and <other>")
    end
    result
  end

  def equ (x, y)
    result = case y.type
    when $Int
      z = x.value == y.value
      # return the singletons not a new value
      if z == true then $true else $false end
    when $Float
      z = x.value == y.value
      if z == true then $true else $false end
    when $Bool
      $false
    else
      TauObject.new($Exception, "Type error: unsupported operand types for ==: Int and <other>")
    end
    result
  end

  def neq (x, y)
    result = case y.type
    when $Int
      z = x.value != y.value
      TauObject.new($Bool, z)
    when $Float
      z = x.value != y.value
      TauObject.new($Bool, z)
    when $Bool
      TauObject.new($Bool, true)
    else
      TauObject.new($Exception, "Type error: unsupported operand types for !=: Int and <other>")
    end
    result
  end

  def gt (x, y)
    result = case y.type
    when $Int
      z = x.value > y.value
      TauObject.new($Bool, z)
    when $Float
      z = x.value > y.value
      TauObject.new($Bool, z)
    when $Bool
      TauObject.new($Exception, "Type error: unsupported operand types for >: Int and Bool")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for >: Int and <other>")
    end
    result
  end

  def lt (x, y)
    result = case y.type
    when $Int
      z = x.value < y.value
      TauObject.new($Bool, z)
    when $Float
      z = x.value < y.value
      TauObject.new($Bool, z)
    when $Bool
      TauObject.new($Exception, "Type error: unsupported operand types for <: Int and Bool")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for <: Int and <other>")
    end
    result
  end

  def ge (x, y)
    result = case y.type
    when $Int
      z = x.value >= y.value
      TauObject.new($Bool, z)
    when $Float
      z = x.value >= y.value
      TauObject.new($Bool, z)
    when $Bool
      TauObject.new($Exception, "Type error: unsupported operand types for >=: Int and Bool")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for >=: Int and <other>")
    end
    result
  end

  def le (x, y)
    result = case y.type
    when $Int
      z = x.value <= y.value
      TauObject.new($Bool, z)
    when $Float
      z = x.value <= y.value
      TauObject.new($Bool, z)
    when $Bool
      TauObject.new($Exception, "Type error: unsupported operand types for <=: Int and Bool")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for <=: Int and <other>")
    end
    result
  end

  def shl (x, y)
    result = case y.type
    when $Int
      z = x.value << y.value
      TauObject.new($Int, z)
    when $Float
      TauObject.new($Exception, "Type error: unsupported operand types for <<: Int and Float")
    when $Bool
      TauObject.new($Exception, "Type error: unsupported operand types for <<: Int and Bool")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for <<: Int and <other>")
    end
    result
  end

  def shr (x, y)
    result = case y.type
    when $Int
      z = x.value >> y.value
      TauObject.new($Int, z)
    when $Float
      TauObject.new($Exception, "Type error: unsupported operand types for >>: Int and Float")
    when $Bool
      TauObject.new($Exception, "Type error: unsupported operand types for >>: Int and Bool")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for >>: Int and <other>")
    end
    result
  end

  def add (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $Int then TauObject.new($Int, x.value + y.value)
      when $Float then TauObject.new($Float, x.value + y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for +: Int and <other>")
      end
    result
  end

  def sub (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $Int then TauObject.new($Int, x.value - y.value)
      when $Float then TauObject.new($Float, x.value - y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for -: Int and <other>")
      end
    result
  end

  def mul (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $Int then TauObject.new($Int, x.value * y.value)
      when $Float then TauObject.new($Float, x.value * y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for *: Int and <other>")
      end
    result
  end

  def div (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $Int then TauObject.new($Int, x.value / y.value)
      when $Float then TauObject.new($Float, x.value / y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for /: Int and <other>")
      end
    result
  end

  def neg (params)
    x = params[0]
    result = TauObject.new($Int, -x.value)
    result
  end

  def bnot (params)
    x = params[0]
    result = TauObject.new($Int, ~x.value)
    result
  end

  def not (params)
    # Need to think about truthy vs. falsy values
    # Do we follow the python/javascript model or the ruby model?
    result = TauObject.new($Bool, false)
    result
  end

  def classObj ()
    @classObj
  end

  def build ()
    @classObj.setMember('super', $Any)

    # Perhaps the value should be an array or some kind of 'NativeCode' ruby
    # object that the interpreter will distinguish at runtime. An array will
    # work for now.  Array is of the form [numParams, code].
    makeFun = TauObject.new($Function, [1, method(:make)])
    @classObj.setMember('make', makeFun)
    
    @classObj.setMember('bor', method(:bor))
    @classObj.setMember('bxor', method(:bxor))
    @classObj.setMember('band', method(:band))
    @classObj.setMember('equ', method(:equ))
    @classObj.setMember('neq', method(:neq))
    @classObj.setMember('gt', method(:gt))
    @classObj.setMember('lt', method(:lt))
    @classObj.setMember('ge', method(:ge))
    @classObj.setMember('le', method(:le))
    @classObj.setMember('shl', method(:shl))
    @classObj.setMember('shr', method(:shr))

    @classObj.setMember('add', TauObject.new($Function, [2, method(:add)]))
    @classObj.setMember('sub', TauObject.new($Function, [2, method(:sub)]))
    @classObj.setMember('mul', TauObject.new($Function, [2, method(:mul)]))
    @classObj.setMember('div', TauObject.new($Function, [2, method(:div)]))

    @classObj.setMember('neg', TauObject.new($Function, [2, method(:neg)]))
    @classObj.setMember('bnot', TauObject.new($Function, [2, method(:bnot)]))
    @classObj.setMember('not', TauObject.new($Function, [2, method(:not)]))
end

end
