class ExceptionBuilder

  def initialize ()
    # Create the Exception class object
    @classObj = TauObject.new($Class, "<class 'Exception'>")
  end

  def make ()
    # Make a new object of type Exception
    TauObject.new($Exception)
  end

  def classObj ()
    @classObj
  end

  def build ()
    @classObj.setMember('super', $Any)
    @classObj.setMember('make', method(:make))
  end

end
