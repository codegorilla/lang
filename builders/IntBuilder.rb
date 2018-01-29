class IntBuilder

  def initialize ()
    @Int = TauObject.new($Class, "<class 'Int'>")
  end

  def makeRaw (value)
    TauObject.new(@Int, value)
  end

  def make (params)
    makeRaw(params[0].value)
  end

  def bor (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Int then TauObject.new(@Int, x.value | y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for |: Int and <other>")
      end
    result
  end

  def bxor (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Int then TauObject.new(@Int, x.value ^ y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for ^: Int and <other>")
      end
    result
  end

  def band (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Int then TauObject.new(@Int, x.value & y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for ^: Int and <other>")
      end
    result
  end

  def equ (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Int then
        z = x.value == y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      when $Float then
        z = x.value == y.value
        if z == true then $true else $false end
      else
        $false
      end
    result
  end

  def neq (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Int then
        z = x.value != y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      when $Float then
        z = x.value != y.value
        if z == true then $true else $false end
      else
        $true
      end
    result
  end

  def gt (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Int then TauObject.new($Bool, x.value > y.value)
      when $Float then TauObject.new($Bool, x.value > y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for >: Int and <other>")
      end
    result
  end

  def lt (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Int then TauObject.new($Bool, x.value < y.value)
      when $Float then TauObject.new($Bool, x.value < y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for <: Int and <other>")
      end
    result
  end

  def ge (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Int then TauObject.new($Bool, x.value >= y.value)
      when $Float then TauObject.new($Bool, x.value >= y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for >=: Int and <other>")
      end
    result
  end

  def le (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Int then TauObject.new($Bool, x.value <= y.value)
      when $Float then TauObject.new($Bool, x.value <= y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for <=: Int and <other>")
      end
    result
  end

  def shl (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Int then TauObject.new(@Int, x.value << y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for <<: Int and <other>")
      end
    result
  end

  def shr (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Int then TauObject.new(@Int, x.value >> y.value)
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
      when @Int then TauObject.new(@Int, x.value + y.value)
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
      when @Int then TauObject.new(@Int, x.value - y.value)
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
      when @Int then TauObject.new(@Int, x.value * y.value)
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
      when @Int then TauObject.new(@Int, x.value / y.value)
      when $Float then TauObject.new($Float, x.value / y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for /: Int and <other>")
      end
    result
  end

  def neg (params)
    x = params[0]
    result = TauObject.new(@Int, -x.value)
    result
  end

  def bnot (params)
    x = params[0]
    result = TauObject.new(@Int, ~x.value)
    result
  end

  def not (params)
    # Need to think about truthy vs. falsy values
    # Do we follow the python/javascript model or the ruby model?
    result = $false
    result
  end

  def toString (params)
    x = params[0]
    result = TauObject.new($String, x.value.to_s)
  end

  def classObj ()
    @Int
  end

  def build ()
    @Int.setMember('super', $Any)

    # Perhaps the value should be an array or some kind of 'NativeCode' ruby
    # object that the interpreter will distinguish at runtime. An array will
    # work for now.  Array is of the form [numParams, code].
    makeFun = TauObject.new($Function, [1, method(:make)])
    @Int.setMember('make', makeFun)
    
    @Int.setMember('bor', TauObject.new($Function, [2, method(:bor)]))
    @Int.setMember('bxor', TauObject.new($Function, [2, method(:bxor)]))
    @Int.setMember('band', TauObject.new($Function, [2, method(:band)]))
    @Int.setMember('equ', TauObject.new($Function, [2, method(:equ)]))
    @Int.setMember('neq', TauObject.new($Function, [2, method(:neq)]))
    @Int.setMember('gt', TauObject.new($Function, [2, method(:gt)]))
    @Int.setMember('lt', TauObject.new($Function, [2, method(:lt)]))
    @Int.setMember('ge', TauObject.new($Function, [2, method(:ge)]))
    @Int.setMember('le', TauObject.new($Function, [2, method(:le)]))
    @Int.setMember('shl', TauObject.new($Function, [2, method(:shl)]))
    @Int.setMember('shr', TauObject.new($Function, [2, method(:shr)]))
    @Int.setMember('add', TauObject.new($Function, [2, method(:add)]))
    @Int.setMember('sub', TauObject.new($Function, [2, method(:sub)]))
    @Int.setMember('mul', TauObject.new($Function, [2, method(:mul)]))
    @Int.setMember('div', TauObject.new($Function, [2, method(:div)]))
    @Int.setMember('neg', TauObject.new($Function, [2, method(:neg)]))
    @Int.setMember('bnot', TauObject.new($Function, [1, method(:bnot)]))
    @Int.setMember('not', TauObject.new($Function, [1, method(:not)]))
    @Int.setMember('toString', TauObject.new($Function, [1, method(:toString)]))
  end

end # class
