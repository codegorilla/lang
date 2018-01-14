class NullBuilder
  
    def initialize ()
    end
  
    def make ()
      # Make a new object of type Null
      # We should only ever create one of these because it is a singleton
      TauObject.new($Null)
    end
  
    def build ()
      # Create the Null class object
      obj = TauObject.new($Class, "<class 'Null'>")
      # Set its superclass
      obj.setMember('super', $Any)
      obj.setMember('make', method(:make))
      obj
    end
  
  end
  