class ClassBuilder

  def initialize ()
    # Create the Class class object
    @Class = TauObject.new(nil, "<class 'Class'>")
    @Class.setType(@Class)
  end

  def make (params)
    # Make a new object of type Class
    className = "<class '#{params[0].value}'>"
    TauObject.new(@Class, className)
  end

  def toString (params)
    x = params[0]
    result = TauObject.new($String, x.value.to_s)
  end

  # The type of the 'Class' object is either null or itself.  In other words,
  # It either has no class or it is its own class. Need to figure this out.

  def classObj ()
    @Class
  end

  def build ()
    # Set its superclass -- should it have one? Is this the same as its type?
    @Class.setMember('super', $Any)
    @Class.setMember('make', TauObject.new($Function, [1, method(:make)]))
    @Class.setMember('toString', TauObject.new($Function, [1, method(:toString)]))
  end

end
