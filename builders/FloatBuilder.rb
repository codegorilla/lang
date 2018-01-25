class FloatBuilder

  def initialize ()
    @Float = TauObject.new($Class, "<class 'Int'>")
  end

  def make (params)
    TauObject.new(@Float, params[0].value.to_f)
  end

  def equ (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $Int then
        z = x.value == y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      when @Float then
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
      when $Int then
        z = x.value != y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      when @Float then
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
      when $Int then TauObject.new($Bool, x.value > y.value)
      when @Float then TauObject.new($Bool, x.value > y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for >: Float and <other>")
      end
    result
  end

  def lt (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $Int then TauObject.new($Bool, x.value < y.value)
      when @Float then TauObject.new($Bool, x.value < y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for <: Float and <other>")
      end
    result
  end

  def ge (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $Int then TauObject.new($Bool, x.value >= y.value)
      when @Float then TauObject.new($Bool, x.value >= y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for >=: Float and <other>")
      end
    result
  end

  def le (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $Int then TauObject.new($Bool, x.value <= y.value)
      when @Float then TauObject.new($Bool, x.value <= y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for <=: Float and <other>")
      end
    result
  end

  def add (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $Int then TauObject.new(@Float, x.value + y.value)
      when @Float then TauObject.new(@Float, x.value + y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for +: Float and <other>")
      end
    result
  end

  def sub (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $Int then TauObject.new(@Float, x.value - y.value)
      when @Float then TauObject.new(@Float, x.value - y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for -: Float and <other>")
      end
    result
  end

  def mul (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $Int then TauObject.new(@Float, x.value * y.value)
      when @Float then TauObject.new(@Float, x.value * y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for *: Float and <other>")
      end
    result
  end

  def div (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $Int then TauObject.new(@Float, x.value / y.value)
      when @Float then TauObject.new(@Float, x.value / y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for /: Float and <other>")
      end
    result
  end

  def neg (params)
    x = params[0]
    result = TauObject.new(@Float, -x.value)
    result
  end

  def not (params)
    # Need to think about truthy vs. falsy values
    # Do we follow the python/javascript model or the ruby model?
    result = $false
    result
  end

  def classObj ()
    @Float
  end

  def build ()
    @Float.setMember('super', $Any)

    # Perhaps the value should be an array or some kind of 'NativeCode' ruby
    # object that the interpreter will distinguish at runtime. An array will
    # work for now.  Array is of the form [numParams, code].
    makeFun = TauObject.new($Function, [1, method(:make)])
    @Float.setMember('make', makeFun)
    
    @Float.setMember('equ', TauObject.new($Function, [2, method(:equ)]))
    @Float.setMember('neq', TauObject.new($Function, [2, method(:neq)]))
    @Float.setMember('gt', TauObject.new($Function, [2, method(:gt)]))
    @Float.setMember('lt', TauObject.new($Function, [2, method(:lt)]))
    @Float.setMember('ge', TauObject.new($Function, [2, method(:ge)]))
    @Float.setMember('le', TauObject.new($Function, [2, method(:le)]))
    @Float.setMember('add', TauObject.new($Function, [2, method(:add)]))
    @Float.setMember('sub', TauObject.new($Function, [2, method(:sub)]))
    @Float.setMember('mul', TauObject.new($Function, [2, method(:mul)]))
    @Float.setMember('div', TauObject.new($Function, [2, method(:div)]))
    @Float.setMember('neg', TauObject.new($Function, [2, method(:neg)]))
    @Float.setMember('not', TauObject.new($Function, [2, method(:not)]))
  end

end # class
