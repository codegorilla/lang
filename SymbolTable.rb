class SymbolTable

  def initialize ()
    @table = {}
    
    # Counting function has to be moved to scopes because symbol table doesn't
    # have enough information to properly assign count
    #@counter = 0
  end

  def put (symbol, count)
    @table[symbol] = count
    #@counter += 1
  end

  def get (symbol)
    @table[symbol]
  end

  def table ()
    @table
  end

end #class

