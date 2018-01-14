class ExceptionBuilder

  def initialize ()
  end

  def make ()
    # Make a new object of type Exception
    TauObject.new($Exception)
  end

  def build ()
    # Create the Exception class object
    obj = TauObject.new($Class, "<class 'Exception'>")
    # Set its superclass
    obj.setMember('super', $Any)
    obj.setMember('make', method(:make))
    obj
  end

end
