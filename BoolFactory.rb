class BoolFactory

    def initialize ()
      # It might be better if these factory classes were modules.
      $Bool.setMember('super', $Any)
    end

    def add (x, y)
      #TauObject.new(@EXCEPTION, "Type error: int + bool")
    end

    def sub (x, y)
      #TauObject.new(@EXCEPTION, "Type error: int + bool")
    end    

    def mul (x, y)
      #TauObject.new(@EXCEPTION, "Type error: int + bool")
    end

    def div (x, y)
      #TauObject.new(@EXCEPTION, "Type error: int + bool")
    end

    def bor (x, y)
      result = case y.type
      when $Bool
        z = x.value | y.value
        TauObject.new($Bool, z)
      when $Int
        #TauObject.new(@EXCEPTION, "Type error: bool | int")
      when $Float
        #TauObject.new(@EXCEPTION, "Type error: bool | float")
      #else
        #TauObject.new(@EXCEPTION, "Type error: int + bool")
      end
      result
    end

    def bxor (x, y)
      result = case y.type
      when $Bool
        z = x.value ^ y.value
        TauObject.new($Bool, z)
      when $Int
        #TauObject.new(@EXCEPTION, "Type error: bool | int")
      when $Float
        #TauObject.new(@EXCEPTION, "Type error: bool | float")
      #else
        #TauObject.new(@EXCEPTION, "Type error: int + bool")
      end
      result
    end

    def band (x, y)
      result = case y.type
      when $Bool
        z = x.value & y.value
        TauObject.new($Bool, z)
      when $Int
        #TauObject.new(@EXCEPTION, "Type error: bool | int")
      when $Float
        #TauObject.new(@EXCEPTION, "Type error: bool | float")
      #else
        #TauObject.new(@EXCEPTION, "Type error: int + bool")
      end
      result
    end

    def make ()
      $Bool.setMember('bor', method(:bor))
      $Bool.setMember('bxor', method(:bxor))
      $Bool.setMember('band', method(:band))
    end
end

