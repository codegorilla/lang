class StringBuilder

  def initialize ()
    @classObj = TauObject.new($Class, "<class 'String'>")
  end

  def make (value)
    TauObject.new($String, value)
  end

  def equ (x, y)
    result = case y.type
    when $String
      z = x.value == y.value
      # return the singletons not a new value
      if z == true then $true else $false end
    else
      TauObject.new($Exception, "Type error: unsupported operand types for ==: String and <other>")
    end
    result
  end

  def neq (x, y)
    result = case y.type
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

  def classObj ()
    @classObj
  end

  def build ()
    @classObj.setMember('super', $Any)
    @classObj.setMember('make', method(:make))
    @classObj.setMember('equ', method(:equ))
    @classObj.setMember('neq', method(:neq))
    @classObj.setMember('gt', method(:gt))
    @classObj.setMember('lt', method(:lt))
    @classObj.setMember('ge', method(:ge))
    @classObj.setMember('le', method(:le))
    @classObj.setMember('add', method(:add))
    @classObj.setMember('not', method(:not))
end

end
