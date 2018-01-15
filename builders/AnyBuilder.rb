class AnyBuilder

  def initialize ()
    # Create the Any class object
    @classObj = TauObject.new($Class, "<class 'Any'>")
  end

  def make ()
    # Make a new object of type Any
    TauObject.new($Any)
  end

  def classObj ()
    @classObj
  end

  def build ()
    # Set its superclass -- should it have one? Is this the same as its type?
    @classObj.setMember('super', $Any)
    @classObj.setMember('make', method(:make))
  end

end
