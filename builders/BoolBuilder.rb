class BoolBuilder

  def initialize ()
    @Bool = TauObject.new($Class, "<class 'Bool'>")
    @true = makeRaw(true)
    @false = makeRaw(false)
  end

  def get_true ()
    @true
  end

  def get_false ()
    @false
  end

  def makeRaw (value)
    TauObject.new(@Bool, value)
  end

  def make (params)
    # Make a new object of type Bool
    # There are only two instances of this class, true and false
    # So there is probably no need for this method
    # Would it be unregistered?
    makeRaw(params[0].value)
  end

  def bor (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Bool then makeRaw(x.value | y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for |: Bool and <other>")
      end
    result
  end

  def bxor (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Bool then TauObject.new(@Bool, x.value ^ y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for ^: Bool and <other>")
      end
    result
  end

  def band (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Bool then TauObject.new(@Bool, x.value & y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for &: Bool and <other>")
      end
    result
  end

  def equ (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Bool then
        z = x.value == y.value
        # return the singletons not a new value
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
      when @Bool then
        z = x.value != y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        $true
      end
    result
  end

  def not (params)
    x = params[0]
    result =
      if x.value == true then $false else $true end
    result
  end

  def toString (params)
    x = params[0]
    result = TauObject.new($String, x.value.to_s)
  end

  def classObj ()
    @Bool
  end

  def build ()
    @Bool.setMember('super', $Any)
    @Bool.setMember('make', TauObject.new($Function, [1, method(:make)]))
    @Bool.setMember('bor', TauObject.new($Function, [2, method(:bor)]))
    @Bool.setMember('bxor', TauObject.new($Function, [2, method(:bxor)]))
    @Bool.setMember('band', TauObject.new($Function, [2, method(:band)]))
    @Bool.setMember('equ', TauObject.new($Function, [2, method(:equ)]))
    @Bool.setMember('neq', TauObject.new($Function, [2, method(:neq)]))
    @Bool.setMember('not', TauObject.new($Function, [1, method(:not)]))
    @Bool.setMember('toString', TauObject.new($Function, [1, method(:toString)]))
  end

end
