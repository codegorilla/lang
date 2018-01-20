class IntBuilder

  def initialize ()
    @classObj = TauObject.new($Class, "<class 'Int'>")
  end

  def make (value)
    TauObject.new($Int, value)
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

  def add (x, y)
    result = case y.type
    when $Int
      z = x.value + y.value
      TauObject.new($Int, z)
    when $Float
      z = x.value + y.value
      TauObject.new($Float, z)
    when $Bool
      TauObject.new($Exception, "Type error: unsupported operand types for +: Int and Bool")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for +: Int and <other>")
    end
    result
  end

  def sub (x, y)
    result = case y.type
    when $Int
      z = x.value - y.value
      TauObject.new($Int, z)
    when $Float
      z = x.value - y.value
      TauObject.new($Float, z)
    when $Bool
      TauObject.new($Exception, "Type error: unsupported operand types for -: Int and Bool")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for -: Int and <other>")
    end
    result
  end    

  def mul (x, y)
    result = case y.type
    when $Int
      z = x.value * y.value
      TauObject.new($Int, z)
    when $Float
      z = x.value * y.value
      TauObject.new($Float, z)
    when $Bool
      TauObject.new($Exception, "Type error: unsupported operand types for *: Int and Bool")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for *: Int and <other>")
    end
    result
  end

  def div (x, y)
    result = case y.type
    when $Int
      z = x.value / y.value
      TauObject.new($Int, z)
    when $Float
      z = x.value / y.value
      TauObject.new($Float, z)
    when $Bool
      TauObject.new($Exception, "Type error: unsupported operand types for /: Int and Bool")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for /: Int and <other>")
    end
    result
  end

  def neg (x)
    result = TauObject.new($Int, -x.value)
    result
  end

  def bnot (x)
    result = TauObject.new($Int, ~x.value)
    result
  end

  def not (x)
    # Need to think about this
    # Do we follow the python/javascript model or the ruby model?
    result = TauObject.new($Bool, false)
    result
  end

  def classObj ()
    @classObj
  end

  def build ()
    @classObj.setMember('super', $Any)

    params = ['filename']
    code = lambda { |params| make(params[0].value) }
    makeFun = TauObject.new($NativeFunction, [params, code])
    @classObj.setMember('make', makeFun)
    
    #@classObj.setMember('make', method(:make))
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
    @classObj.setMember('add', method(:add))
    @classObj.setMember('sub', method(:sub))
    @classObj.setMember('mul', method(:mul))
    @classObj.setMember('div', method(:div))
    @classObj.setMember('neg', method(:neg))
    @classObj.setMember('bnot', method(:bnot))
    @classObj.setMember('not', method(:not))
end

end
