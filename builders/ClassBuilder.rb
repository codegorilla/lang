class ClassBuilder

  def initialize ()
    # Create the Class class object
    @classObj = TauObject.new(nil, "<class 'Class'>")
    @classObj.setType(@classObj)
  end

  def make ()
    # Make a new object of type Class
    TauObject.new(@classObj)
  end

  def toString (params)
    x = params[0]
    result = TauObject.new($String, x.value.to_s)
  end

  # The type of the 'Class' object is either null or itself.  In other words,
  # It either has no class or it is its own class. Need to figure this out.

  def classObj ()
    @classObj
  end

  def build ()
    # Set its superclass -- should it have one? Is this the same as its type?
    @classObj.setMember('super', $Registry['Any'])
    @classObj.setMember('make', method(:make))
    @classObj.setMember('toString', TauObject.new($Function, [1, method(:toString)]))
  end

end
