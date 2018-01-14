class AnyBuilder

  def initialize ()
  end

  def make ()
    # Make a new object of type Any
    TauObject.new($Any)
  end

  def build ()
    # Create the Any class object
    obj = TauObject.new($Class, "<class 'Any'>")
    # Set its superclass -- should it have one? Is this the same as its type?
    obj.setMember('super', $Any)
    obj.setMember('make', method(:make))
    obj
  end

end
