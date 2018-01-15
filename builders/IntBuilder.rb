class IntBuilder

  def initialize ()
    @classObj = TauObject.new($Class, "<class 'Int'>")
  end

  def make (value)
    TauObject.new($Int, value)
  end

  def classObj ()
    @classObj
  end

  def build ()
    @classObj.setMember('super', $Any)
  end

end
