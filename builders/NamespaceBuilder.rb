class NamespaceBuilder

  def initialize ()
    @classObj = TauObject.new($Class, "<class 'Namespace'>")
  end

  def make (params)
    TauObject.new($Namespace, '<namespace>')
  end

  def classObj ()
    @classObj
  end

  def build ()
    @classObj.setMember('super', $Any)

    makeFun = TauObject.new($Function, [0, method(:make)])
    @classObj.setMember('make', makeFun)
  end

end
