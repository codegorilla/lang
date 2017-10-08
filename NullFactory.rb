class NullFactory

    def initialize ()
      # It might be better if these factory classes were modules.
      $Null.setMember('super', $Any)
    end

    def equ (x, y)
      result = case y.type
      when $Null
        TauObject.new($Bool, true)
      else
        TauObject.new($Bool, false)
      end
      result
    end

    def neq (x, y)
      result = case y.type
      when $Null
        TauObject.new($Bool, false)
      else
        TauObject.new($Bool, true)
      end
      result
    end

    def make ()
      $Null.setMember('equ', method(:equ))
      $Null.setMember('neq', method(:neq))
    end
end