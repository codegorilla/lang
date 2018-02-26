class Scope

  def initialize (kind, level = 0, link = nil)
    @kind = kind
    @level = level
    @link = link
    @symbols = SymbolTable.new
    @objectFlag = false

    # A scope starts off with a counter that increases each time a variable is
    # added to the scope
    # The goal is to ensure that all local variables will have a unique index
    #@counter = 0
    # In order to make that happen, a child scope must inherit the current value
    # of its parent scope

    # Counter should only be used for local scopes, not global

    if @link != nil
      @counter = @link.counter
      #puts "The counter value is #{@counter}!"
    else
      @counter = 0
    end
  end

  def globalScope? ()
    link == nil
  end

  def counter ()
    @counter
  end

  def setCounter (count)
    @counter = count
  end

  def kind ()
    @kind
  end

  def level ()
    @level
  end

  def link ()
    @link
  end

  def symbols ()
    @symbols
  end

  def define (name)
    if globalScope? then
      @symbols.put(name, -1)
    else
      @symbols.put(name, counter)
      @counter += 1
    end
  end

  def lookup (name)
    @symbols.get(name)
  end

  def resolve (name)
    # Eventually, this needs to be defined to recurse.
    # Depends whether there is ever a need to recurse at compile time.
    @symbols.get(name)
  end

  def setObjectFlag (bool)
    @objectFlag = bool
  end

  def objectFlag ()
    @objectFlag
  end

end #class

