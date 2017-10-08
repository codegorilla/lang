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

    def add (x, y)
    end

    def sub (x, y)
    end    

    def mul (x, y)
    end

    def div (x, y)
    end
    
    def make ()
      $Bool.setMember('bor', method(:bor))
      $Bool.setMember('bxor', method(:bxor))
      $Bool.setMember('band', method(:band))
    end
end

