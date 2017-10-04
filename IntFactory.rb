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
        #TauObject.new(@EXCEPTION, "Type error: int + bool")
      #else
        #TauObject.new(@EXCEPTION, "Type error: int + bool")
      end
      result
    end

    def bxor (x, y)
      result = case y.type
      when $Int
        z = x.value ^ y.value
        TauObject.new($Int, z)
      when $Float
        #TauObject.new(@EXCEPTION, "Type error: int + bool")
      #else
        #TauObject.new(@EXCEPTION, "Type error: int + bool")
      end
      result
    end

    def band (x, y)
      result = case y.type
      when $Int
        z = x.value & y.value
        TauObject.new($Int, z)
      when $Float
        #TauObject.new(@EXCEPTION, "Type error: int + bool")
      #else
        #TauObject.new(@EXCEPTION, "Type error: int + bool")
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
      #else
        #TauObject.new(@EXCEPTION, "Type error: int + bool")
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
      #else
        #TauObject.new(@EXCEPTION, "Type error: int + bool")
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
      #else
        #TauObject.new(@EXCEPTION, "Type error: int + bool")
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
      #else
        #TauObject.new(@EXCEPTION, "Type error: int + bool")
      end
      result
    end

    def make ()
      $Int.setMember('bor', method(:bor))
      $Int.setMember('bxor', method(:bxor))
      $Int.setMember('band', method(:band))
      $Int.setMember('add', method(:add))
      $Int.setMember('sub', method(:sub))
      $Int.setMember('mul', method(:mul))
      $Int.setMember('div', method(:div))
    end
end