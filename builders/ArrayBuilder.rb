class ArrayBuilder

  def initialize ()
    @Array = TauObject.new($Class, "<class 'Array'>")
  end

  def makeRaw (value)
    TauObject.new(@Array, value)
  end

  def make (params)
    makeRaw(params[0].value)
  end

  def equ (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Array
        # Might need to compare items individually
        if x.value == y.value then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for ==: Array and <other>")
      end
    result
  end

  def neq (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Array
        if x.value != y.value then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for !=: Array and <other>")
      end
    result
  end

  def add (params)
    x = params[0]
    y = params[1]
    result = case y.type
    when @Array
      makeRaw(x.value + y.value)
    else
      TauObject.new($Exception, "Type error: unsupported operand types for +: Array and <other>")
    end
    result
  end

  def not (params)
    $false
  end

  def concat (params)
    x = params[0]
    y = params[1]
    result = case y.type
    when @Array
      makeRaw(x.value + y.value)
    else
      TauObject.new($Exception, "Type error: unsupported operand types for +: Array and <other>")
    end
    result
  end

  def length (params)
    TauObject.new($Int, params[0].value.length)
  end

  def reverse (params)
    makeRaw(params[0].value.reverse)
  end

  def classObj ()
    @Array
  end

  def build ()
    @Array.setMember('super', $Any)
    @Array.setMember('make', TauObject.new($Function, [0, method(:make)]))
    @Array.setMember('equ', TauObject.new($Function, [2, method(:equ)]))
    @Array.setMember('neq', TauObject.new($Function, [2, method(:neq)]))
    @Array.setMember('add', TauObject.new($Function, [2, method(:add)]))
    @Array.setMember('not', TauObject.new($Function, [1, method(:not)]))
    @Array.setMember('concat', TauObject.new($Function, [2, method(:concat)]))
    @Array.setMember('length', TauObject.new($Function, [1, method(:length)]))
    @Array.setMember('reverse', TauObject.new($Function, [1, method(:reverse)]))
  end

end