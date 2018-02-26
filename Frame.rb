class Frame

  def initialize (dynamicLink = nil, staticLink = nil)
    @dynamicLink = dynamicLink
    @staticLink = staticLink

    # Locals array
    @locals = []

    # Block stack
    @blocks = []

    # Block pointer
    @bp = -1

    # Operand stack
    @stack = []
  end

  def dynamicLink ()
    @dynamicLink
  end

  def staticLink ()
    @staticLink
  end

  # how to access...
  # y = x + 1;
  # x is an identifier node, so check the lexical scope for the name
  # the lexical scope is stored in the AST as an attribute at each block node
  # Thus, each time we enter a block we can load the lexical scope
  # lookup(x) will yield an index into the local table
  # The problem is if it is non-local.  Walking the scope tree upwards might
  # yield an index, but we won't know which frame holds the corresponding local
  # table, because the scopes are compile-time entities that don't point to
  # runtime frames. This is where the static link (aka access link) comes into
  # play.  Need to compute the access link.

  # deprecate
  def store (index, value)
    @locals[index] = value
  end

  # deprecate
  def load (index)
    @locals[index]
  end

  def blocks ()
    @blocks
  end

  def bp ()
    @bp
  end

  def currentBlock ()
    @blocks[@bp]
  end

  def pushBlock ()
    @bp += 1
    @blocks[@bp] = Block.new
  end

  def popBlock ()
    @bp -= 1
  end

  def blocklocals ()
    @blocklocals
  end

  def locals ()
    @locals
  end

  def stack ()
    @stack
  end

end

