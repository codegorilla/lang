class NativeFunctionBuilder

  def initialize ()
    @classObj = TauObject.new($Class, "<class 'NativeFunction'>")
  end

  def make (value)
    # Where does this get used?
    # I think when we create functions, we've created them manually
    # Need to convert them to calls to $NativeFunction.make
    TauObject.new($NativeFunction, value)
  end

  def call ()
    puts "You called a native function"
  end

  def classObj ()
    @classObj
  end

  def build ()
    @classObj.setMember('super', $Any)
    @classObj.setMember('make', method(:make))
    @classObj.setMember('call', method(:call))
  end

end
