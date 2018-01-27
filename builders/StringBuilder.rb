class StringBuilder

  def initialize ()
    @String = TauObject.new($Class, "<class 'String'>")
  end

  def makeRaw (value)
    TauObject.new($String, value)
  end

  def make (params)
    makeRaw(params[0].value)
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

  def gt (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $String
        z = x.value > y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for >: String and <other>")
      end
    result
  end

  def lt (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $String
        z = x.value < y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for <: String and <other>")
      end
    result
  end

  def ge (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $String
        z = x.value >= y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for >=: String and <other>")
      end
    result
  end

  def le (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $String
        z = x.value <= y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for <=: String and <other>")
      end
    result
  end

  def add (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $String
        makeRaw(x.value + y.value)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for +: String and <other>")
      end
      result
  end

  def not (params)
    $false
  end

  def capitalize (params)
    makeRaw(params[0].value.capitalize)
  end

  def concat (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when $String
        makeRaw(x.value + y.value)
      else
        TauObject.new($Exception, "Type error: unsupported types for concat: String and <other>")
      end
    result
  end

  def length (params)
    TauObject.new($Int, params[0].value.length)
  end

  def reverse (params)
    makeRaw(params[0].value.reverse)
  end

  def lower (params)
    makeRaw(params[0].value.downcase)
  end

  def upper (params)
    makeRaw(params[0].value.upcase)
  end

  def toString (params)
    # Just return the string
    params[0]
  end

  def classObj ()
    @String
  end

  def build ()
    @String.setMember('super', $Any)
    @String.setMember('make', TauObject.new($Function, [2, method(:make)]))
    @String.setMember('equ', TauObject.new($Function, [2, method(:equ)]))
    @String.setMember('neq', TauObject.new($Function, [2, method(:neq)]))
    @String.setMember('gt', TauObject.new($Function, [2, method(:gt)]))
    @String.setMember('lt', TauObject.new($Function, [2, method(:lt)]))
    @String.setMember('ge', TauObject.new($Function, [2, method(:ge)]))
    @String.setMember('le', TauObject.new($Function, [2, method(:le)]))
    @String.setMember('add', TauObject.new($Function, [2, method(:add)]))
    @String.setMember('not', TauObject.new($Function, [1, method(:not)]))
    @String.setMember('capitalize', TauObject.new($Function, [2, method(:capitalize)]))
    @String.setMember('concat', TauObject.new($Function, [2, method(:concat)]))
    @String.setMember('length', TauObject.new($Function, [1, method(:length)]))
    @String.setMember('reverse', TauObject.new($Function, [1, method(:reverse)]))
    @String.setMember('lower', TauObject.new($Function, [1, method(:lower)]))
    @String.setMember('upper', TauObject.new($Function, [1, method(:upper)]))
    @String.setMember('toString', TauObject.new($Function, [1, method(:toString)]))
  end

end
