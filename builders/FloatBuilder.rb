class FloatBuilder

    def initialize ()
      @classObj = TauObject.new($Class, "<class 'Float'>")
    end

    def make (value)
      TauObject.new($Float, value)
    end

    def classObj ()
      @classObj
    end

    def equ (x, y)
      result = case y.type
      when $Int
        z = x.value == y.value
        TauObject.new($Bool, z)
      when $Float
        z = x.value == y.value
        TauObject.new($Bool, z)
      when $Bool
        TauObject.new($Bool, false)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for ==: Float and <other>")
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
        TauObject.new($Exception, "Type error: unsupported operand types for !=: Float and <other>")
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
        TauObject.new($Exception, "Type error: unsupported operand types for >: Float and Bool")
      else
        TauObject.new($Exception, "Type error: unsupported operand types for >: Float and <other>")
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
        TauObject.new($Exception, "Type error: unsupported operand types for <: Float and Bool")
      else
        TauObject.new($Exception, "Type error: unsupported operand types for <: Float and <other>")
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
        TauObject.new($Exception, "Type error: unsupported operand types for >=: Float and Bool")
      else
        TauObject.new($Exception, "Type error: unsupported operand types for >=: Float and <other>")
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
        TauObject.new($Exception, "Type error: unsupported operand types for <=: Float and Bool")
      else
        TauObject.new($Exception, "Type error: unsupported operand types for <=: Float and <other>")
      end
      result
    end

    def add (x, y)
      result = case y.type
      when $Int
        z = x.value + y.value
        TauObject.new($Float, z)
      when $Float
        z = x.value + y.value
        TauObject.new($Float, z)
      when $Bool
        TauObject.new($Exception, "Type error: unsupported operand types for +: Float and Bool")
      else
        TauObject.new($Exception, "Type error: unsupported operand types for +: Float and <other>")
      end
      result
    end

    def sub (x, y)
      result = case y.type
      when $Int
        z = x.value - y.value
        TauObject.new($Float, z)
      when $Float
        z = x.value - y.value
        TauObject.new($Float, z)
      when $Bool
        TauObject.new($Exception, "Type error: unsupported operand types for -: Float and Bool")
      else
        TauObject.new($Exception, "Type error: unsupported operand types for -: Float and <other>")
      end
      result
    end    

    def mul (x, y)
      result = case y.type
      when $Int
        z = x.value * y.value
        TauObject.new($Float, z)
      when $Float
        z = x.value * y.value
        TauObject.new($Float, z)
      when $Bool
        TauObject.new($Exception, "Type error: unsupported operand types for *: Float and Bool")
      else
        TauObject.new($Exception, "Type error: unsupported operand types for *: Float and <other>")
      end
      result
    end

    def div (x, y)
      result = case y.type
      when $Int
        z = x.value / y.value
        TauObject.new($Float, z)
      when $Float
        z = x.value / y.value
        TauObject.new($Float, z)
      when $Bool
        TauObject.new($Exception, "Type error: unsupported operand types for /: Float and Bool")
      else
        TauObject.new($Exception, "Type error: unsupported operand types for /: Float and <other>")
      end
      result
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
      @classObj.setMember('sub', method(:sub))
      @classObj.setMember('mul', method(:mul))
      @classObj.setMember('div', method(:div))
    end

  end
