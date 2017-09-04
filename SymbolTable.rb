class SymbolTable

  def initialize ()
    @table = {}
    @counter = 0
  end

  def insert (name)
    @table[name] = @counter
    @counter += 1
  end

  def lookup (name)
    @table[name]
  end

end #class

