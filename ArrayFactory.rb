class ArrayFactory

    def initialize ()
      # It might be better if these factory classes were modules.
      $Array.setMember('super', $Any)
    end

    def equ (x, y)
      result = case y.type
      when $Array
        z = x.value == y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for ==: Array and <other>")
      end
      result
    end

    def neq (x, y)
      result = case y.type
      when $Array
        z = x.value != y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for !=: Array and <other>")
      end
      result
    end

    def gt (x, y)
      result = case y.type
      when $Array
        z = x.value > y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for >: Array and <other>")
      end
      result
    end

    def lt (x, y)
      result = case y.type
      when $Array
        z = x.value < y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for <: Array and <other>")
      end
      result
    end

    def ge (x, y)
      result = case y.type
      when $Array
        z = x.value >= y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for >=: Array and <other>")
      end
      result
    end

    def le (x, y)
      result = case y.type
      when $Array
        z = x.value <= y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for <=: Array and <other>")
      end
      result
    end

    def add (x, y)
      result = case y.type
      when $Array
        z = x.value + y.value
        TauObject.new($String, z)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for +: Array and <other>")
      end
      result
    end

    def not (x)
      # Need to think about this
      # Do we follow the python/javascript model or the ruby model?
      result = TauObject.new($Bool, false)
      result
    end

    def make ()
      $Array.setMember('equ', method(:equ))
      $Array.setMember('neq', method(:neq))
      $Array.setMember('gt', method(:gt))
      $Array.setMember('lt', method(:lt))
      $Array.setMember('ge', method(:ge))
      $Array.setMember('le', method(:le))
      $Array.setMember('add', method(:add))
      $Array.setMember('not', method(:not))
    end
    
end # class

