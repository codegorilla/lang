class NamespaceBuilder

  def initialize ()
    @classObj = TauObject.new($Class, "<class 'Namespace'>")
  end

  def make ()
    TauObject.new($Namespace, '<namespace>')
  end

  def classObj ()
    @classObj
  end

  def build ()
    @classObj.setMember('super', $Any)

    params = ['filename']
    code = lambda { |params| make }
    makeFun = TauObject.new($NativeFunction, [params, code])
    #makeFun = $NativeFunction.make([params, code])
    mkFun = $NativeFunction.getMember('make')
    cdFun = mkFun.value[1]
    pp cdFun
    #cdFun.call()
    #callFun = $NativeFunction.getMember('call')
    #puts callFun

    @classObj.setMember('make', makeFun)
  end

end
