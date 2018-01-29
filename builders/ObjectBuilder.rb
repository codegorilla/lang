class ObjectBuilder

  def initialize ()
    # Create the Object class object
    @Object = TauObject.new($Class, "<class 'Object'>")
  end

  def make (params)
    # Make a new object of type Object
    instance = TauObject.new(@Object)
    # Initialize the object
    init(instance)
  end

  def init (this)
    # Initialize the object
  end

  def toString (params)
    x = params[0]
    result = TauObject.new($String, x.value.to_s)
  end
  
  def classObj ()
    @Object
  end

  def build ()
    # Set its superclass -- should it have one? Is this the same as its type?
    @Object.setMember('super', $Any)
    @Object.setMember('make', TauObject.new($Function, [0, method(:make)]))
    @Object.setMember('toString', TauObject.new($Function, [1, method(:toString)]))
  end

end # class

