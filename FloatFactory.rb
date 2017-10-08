class FloatFactory

    def initialize ()
      $Float.setMember('super', $Any)
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

    def make ()
      $Float.setMember('equ', method(:equ))
      $Float.setMember('neq', method(:neq))
      $Float.setMember('gt', method(:gt))
      $Float.setMember('lt', method(:lt))
      $Float.setMember('ge', method(:ge))
      $Float.setMember('le', method(:le))
      $Float.setMember('add', method(:add))
      $Float.setMember('sub', method(:sub))
      $Float.setMember('mul', method(:mul))
      $Float.setMember('div', method(:div))
    end
end