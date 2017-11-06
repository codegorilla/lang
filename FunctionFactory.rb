class FunctionFactory

    def initialize ()
      # It might be better if these factory classes were modules.
      $Function.setMember('super', $Any)
    end

    def call ()
      puts "You called a function"
    end

    def make ()
      $Function.setMember('call', method(:call))
    end

end # class

