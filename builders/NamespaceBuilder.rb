class NamespaceBuilder

  def initialize ()
    @classObj = TauObject.new($Class, "<class 'Namespace'>")
  end

  def make (params)
    TauObject.new($Namespace, '<namespace>')
  end

  def toString (params)
    x = params[0]
    result = TauObject.new($String, x.value.to_s)
  end

  def classObj ()
    @classObj
  end

  def build ()
    @classObj.setMember('super', $Any)

    makeFun = TauObject.new($Function, [0, method(:make)])
    @classObj.setMember('make', makeFun)
    @classObj.setMember('toString', TauObject.new($Function, [1, method(:toString)]))
  end

end
