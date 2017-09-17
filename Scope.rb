class Scope

  def initialize (link = nil)
    @link = link
    @symbols = SymbolTable.new
  end

  # Probably dont need this anymore - creating a new scope will always create a new symbol table
  # def setSymbolTable (st)
  #  @symbols = st
  #end

  def symbols ()
    @symbols
  end

  def link ()
    @link
  end

  def define (symbol)
    @symbols.insert(symbol)
  end

end #class
