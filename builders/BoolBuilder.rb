class BoolBuilder

  def initialize ()
    # Create the Bool class object
    @classObj = TauObject.new($Class, "<class 'Bool'>")
    # Singleton true and false
    @true = TauObject.new(@classObj, true)
    @false = TauObject.new(@classObj, false)
  end

  def get_true ()
    @true
  end

  def get_false ()
    @false
  end

  def make (value)
    # Make a new object of type Bool
    # There are only two instances of this class, true and false
    # So there is probably no need for this method
    # Would it be unregistered?
    TauObject.new($Bool, value)
  end

  def bor (x, y)
    result = case y.type
    when $Bool
      z = x.value | y.value
      TauObject.new($Bool, z)
    when $Int
      TauObject.new($Exception, "Type error: unsupported operand types for |: Bool and Int")
    when $Float
      TauObject.new($Exception, "Type error: unsupported operand types for |: Bool and Float")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for |: Bool and <other>")
    end
    result
  end

  def bxor (x, y)
    result = case y.type
    when $Bool
      z = x.value ^ y.value
      TauObject.new($Bool, z)
    when $Int
      TauObject.new($Exception, "Type error: unsupported operand types for ^: Bool and Int")
    when $Float
      TauObject.new($Exception, "Type error: unsupported operand types for ^: Bool and Float")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for ^: Bool and <other>")
    end
    result
  end

  def band (x, y)
    result = case y.type
    when $Bool
      z = x.value & y.value
      TauObject.new($Bool, z)
    when $Int
      TauObject.new($Exception, "Type error: unsupported operand types for &: Bool and Int")
    when $Float
      TauObject.new($Exception, "Type error: unsupported operand types for &: Bool and Float")
    else
      TauObject.new($Exception, "Type error: unsupported operand types for &: Bool and <other>")
    end
    result
  end

  def equ (x, y)
    result = case y.type
    when $Bool
      z = x.value == y.value
      if z == true then $true else $false end
      #TauObject.new($Bool, z)
    when $Int
      $false
    when $Float
      $false
    else
      $false
    end
    result
  end

  def neq (x, y)
    result = case y.type
    when $Bool
      z = x.value != y.value
      TauObject.new($Bool, z)
    when $Int
      $true
    when $Float
      $true
    else
      $true
    end
    result
  end

  def not (x)
    result = TauObject.new($Bool, !x.value)
    result
  end

  def classObj ()
    @classObj
  end

  def build ()
    @classObj.setMember('super', $Any)
    @classObj.setMember('make', method(:make))
    @classObj.setMember('bor', method(:bor))
    @classObj.setMember('bxor', method(:bxor))
    @classObj.setMember('band', method(:band))
    @classObj.setMember('equ', method(:equ))
    @classObj.setMember('neq', method(:neq))
    @classObj.setMember('not', method(:not))
  end

end
