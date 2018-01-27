class NamespaceBuilder

  def initialize ()
    @Namespace = TauObject.new($Class, "<class 'Namespace'>")
  end

  def make (params)
    TauObject.new(@Namespace, '<namespace>')
  end

  def toString (params)
    x = params[0]
    result = TauObject.new($String, x.value.to_s)
  end

  def classObj ()
    @Namespace
  end

  def build ()
    @Namespace.setMember('super', $Any)
    @Namespace.setMember('make', TauObject.new($Function, [0, method(:make)]))
    @Namespace.setMember('toString', TauObject.new($Function, [1, method(:toString)]))
  end

end
