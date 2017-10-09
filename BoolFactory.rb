class BoolFactory

    def initialize ()
      # It might be better if these factory classes were modules.
      $Bool.setMember('super', $Any)
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
        TauObject.new($Exception, "Type error: unsupported operand types for |: Bool and Int")
      when $Float
        TauObject.new($Exception, "Type error: unsupported operand types for |: Bool and Float")
      else
        TauObject.new($Exception, "Type error: unsupported operand types for |: Bool and <other>")
      end
      result
    end

    def band (x, y)
      result = case y.type
      when $Bool
        z = x.value & y.value
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

    def equ (x, y)
      result = case y.type
      when $Bool
        z = x.value == y.value
        TauObject.new($Bool, z)
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

    # Should Bool type be promoted to Int so that add, sub, mul, div and
    # other numerical operators work? Python does this, but Ruby does not.
    
    def make ()
      $Bool.setMember('bor', method(:bor))
      $Bool.setMember('bxor', method(:bxor))
      $Bool.setMember('band', method(:band))
      $Bool.setMember('equ', method(:equ))
      $Bool.setMember('neq', method(:neq))
      $Bool.setMember('not', method(:not))
    end
end

