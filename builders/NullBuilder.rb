class NullBuilder

  def initialize ()
    # Create the Null class object
    @Null = TauObject.new($Class, "<class 'Null'>")
    @null = makeRaw
  end

  def get_null ()
    @null
  end

  def makeRaw ()
    TauObject.new(@Null, nil)
  end

  def make (params)
    # Make a new object of type Null
    # We should only ever create one of these because it is a singleton
    makeRaw
  end

  def equ (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Null
        $true
      else
        $false
      end
    result
  end

  def neq (params)
    x = params[0]
    y = params[1]
    result =
      case y.type
      when @Null
        $false
      else
        $true
      end
    result
  end

  def not (params)
    # null is a 'falsy' value so !null is true
    result = $true
    result
  end

  def toString (params)
    x = params[0]
    result = TauObject.new($String, x.value.to_s)
  end
  
  def classObj ()
    @Null
  end

  def build ()
    @Null.setMember('super', $Any)
    @Null.setMember('make', TauObject.new($Function, [0, method(:make)]))
    @Null.setMember('equ', TauObject.new($Function, [2, method(:equ)]))
    @Null.setMember('neq', TauObject.new($Function, [2, method(:neq)]))
    @Null.setMember('not', TauObject.new($Function, [1, method(:not)]))
    @Null.setMember('toString', TauObject.new($Function, [1, method(:toString)]))
  end

end # class
