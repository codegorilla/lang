class UnitBuilder

  def initialize ()
    # Create the Unit class object
    @classObj = TauObject.new($Class, "<class 'Unit'>")
    @unit = TauObject.new(@classObj, "()")
  end

  def get_unit ()
    @unit
  end

  def make ()
    # Make a new object of type Unit
    # We should only ever create one of these because it is a singleton
    # Might not need this method
    TauObject.new($Unit, "()")
  end

  def classObj ()
    @classObj
  end

  def build ()
    @classObj.setMember('super', $Any)
    @classObj.setMember('make', method(:make))
  end

end
