class NullBuilder

  def initialize ()
    # Create the Null class object
    @classObj = TauObject.new($Class, "<class 'Null'>")
    @null = TauObject.new(@classObj, nil)
  end

  def get_null ()
    @null
  end

  def make ()
    # Make a new object of type Null
    # We should only ever create one of these because it is a singleton
    TauObject.new($Null)
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

  def classObj ()
    @classObj
  end

  def build ()
    @classObj.setMember('super', $Any)
    @classObj.setMember('make', method(:make))
  end

end
