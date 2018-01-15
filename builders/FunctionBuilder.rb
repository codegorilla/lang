class FunctionBuilder

  # Function objects might need more work, different one based on number of
  # parameters
  # $Function1, $Function2, etc...

  def initialize ()
    @classObj = TauObject.new($Class, "<class 'Function'>")
  end

  def make (value)
    # Where does this get used?
    # I think when we create functions, we've created them manually
    # Need to convert them to calls to $Function.make
    TauObject.new($Function, value)
  end

  def call ()
    puts "You called a function"
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