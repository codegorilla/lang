class UnitBuilder
  
    def initialize ()
    end
  
    def make ()
      # Make a new object of type Unit
      # We should only ever create one of these because it is a singleton
      TauObject.new($Null)
    end
  
    def build ()
      # Create the Unit class object
      obj = TauObject.new($Class, "<class 'Unit'>")
      # Set its superclass
      obj.setMember('super', $Any)
      obj.setMember('make', method(:make))
      obj
    end
  
  end
  