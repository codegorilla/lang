class Scope

  def initialize (link = nil)
    @link = link
    @symbols = SymbolTable.new
  end

  def symbols ()
    @symbols
  end

  def link ()
    @link
  end

  def define (name)
    @symbols.put(name)
  end

  def lookup (name)
    @symbols.get(name)
  end

  def resolve (name)
    # Eventually, this needs to be defined to recurse.
    # Depends whether there is ever a need to recurse at compile time.
    @symbols.get(name)
  end

end #class

