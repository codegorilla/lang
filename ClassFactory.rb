class ClassFactory

  def initialize ()
    $Class.setMember('super', $Any)
  end

  def make ()
    # Make a new class
    TauObject.new($Class)
  end

end
