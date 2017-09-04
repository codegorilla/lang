class Scope

  def initialize (link = nil)
    @link = link
  end

  def setSymbolTable (st)
    @st = st
  end

  def st ()
    @st
  end

  def link ()
    @link
  end

end #class