class SymbolTable

  def initialize ()
    @table = {}
    @counter = 0
  end

  def put (symbol)
    @table[symbol] = @counter
    @counter += 1
  end

  def get (symbol)
    @table[symbol]
  end

  def table ()
    @table
  end

end #class

