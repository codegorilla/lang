class Block

  def initialize ()
    @locals = []
  end

  def locals ()
    @locals
  end

  def store (index, value)
    @locals[index] = value
  end

  def load (index)
    @locals[index]
  end

end # class