class FloatFactory

    def initialize ()
      $Float.setMember('super', $Any)
    end

    def add (x, y)
      result = case y.type
      when $Int
        z = x.value + y.value
        TauObject.new($Float, z)
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
        TauObject.new($Float, z)
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
        TauObject.new($Float, z)
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
        TauObject.new($Float, z)
      when $Float
        z = x.value / y.value
        TauObject.new($Float, z)
      #else
        #TauObject.new(@EXCEPTION, "Type error: int + bool")
      end
      result
    end

    def make ()
      $Float.setMember('add', method(:add))
      $Float.setMember('sub', method(:sub))
      $Float.setMember('mul', method(:mul))
      $Float.setMember('div', method(:div))
    end
end