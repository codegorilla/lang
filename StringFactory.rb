class StringFactory

    def initialize ()
      # It might be better if these factory classes were modules.
      $String.setMember('super', $Any)
    end

    def equ (x, y)
      result = case y.type
      when $String
        z = x.value == y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for ==: String and <other>")
      end
      result
    end

    def neq (x, y)
      result = case y.type
      when $String
        z = x.value != y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for !=: String and <other>")
      end
      result
    end

    def gt (x, y)
      result = case y.type
      when $String
        z = x.value > y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for >: String and <other>")
      end
      result
    end

    def lt (x, y)
      result = case y.type
      when $String
        z = x.value < y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for <: String and <other>")
      end
      result
    end

    def ge (x, y)
      result = case y.type
      when $String
        z = x.value >= y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for >=: String and <other>")
      end
      result
    end

    def le (x, y)
      result = case y.type
      when $String
        z = x.value <= y.value
        # return the singletons not a new value
        if z == true then $true else $false end
      else
        TauObject.new($Exception, "Type error: unsupported operand types for <=: String and <other>")
      end
      result
    end

    def add (x, y)
      result = case y.type
      when $String
        z = x.value + y.value
        TauObject.new($String, z)
      else
        TauObject.new($Exception, "Type error: unsupported operand types for +: String and <other>")
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
      $String.setMember('equ', method(:equ))
      $String.setMember('neq', method(:neq))
      $String.setMember('gt', method(:gt))
      $String.setMember('lt', method(:lt))
      $String.setMember('ge', method(:ge))
      $String.setMember('le', method(:le))
      $String.setMember('add', method(:add))
      $String.setMember('not', method(:not))
    end
    
end # class

