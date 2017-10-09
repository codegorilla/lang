class IntFactory

    def initialize ()
      # It might be better if these factory classes were modules.
      $Int.setMember('super', $Any)
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
        TauObject.new($Bool, z)
      when $Float
        z = x.value == y.value
        TauObject.new($Bool, z)
      when $Bool
        TauObject.new($Bool, false)
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

    def make ()
      $Int.setMember('bor', method(:bor))
      $Int.setMember('bxor', method(:bxor))
      $Int.setMember('band', method(:band))
      $Int.setMember('equ', method(:equ))
      $Int.setMember('neq', method(:neq))
      $Int.setMember('gt', method(:gt))
      $Int.setMember('lt', method(:lt))
      $Int.setMember('ge', method(:ge))
      $Int.setMember('le', method(:le))
      $Int.setMember('shl', method(:shl))
      $Int.setMember('shr', method(:shr))
      $Int.setMember('add', method(:add))
      $Int.setMember('sub', method(:sub))
      $Int.setMember('mul', method(:mul))
      $Int.setMember('div', method(:div))
      $Int.setMember('neg', method(:neg))
      $Int.setMember('bnot', method(:bnot))
      $Int.setMember('not', method(:not))
    end
end