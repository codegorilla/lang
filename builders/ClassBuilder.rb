class ClassBuilder

  def initialize ()
  end

  def make ()
    # Make a new object of type Class
    TauObject.new($Class)
  end

  # The type of the 'Class' object is either null or itself.  In other words,
  # It either has no class or it is its own class. Need to figure this out.

  def build ()
    # Create the Class class object
    obj = TauObject.new(nil, "<class 'Class'>")
    # Set its superclass -- should it have one? Is this the same as its type?
    obj.setMember('super', $Any)
    obj.setMember('make', method(:make))
    obj
  end

end
