class Node

  def initialize (kind, text = nil)
    @kind = kind
    @text = text
    @zchildren = []

    # This is a test about associating some token information with the node
    # Might delete this field
    @line = 0

    # Syntesized attributes
    @attributes = {}
  end

  NULL_LITERAL = Node.new(:NULL_LITERAL, "null")
  UNIT_LITERAL = Node.new(:UNIT_LITERAL, "()")

  # Test about associating token info with node
  # Might delete this method
  def setLine (line)
    @line = line
  end
  
  def line ()
    @line
  end

  def setText (text)
    @text = text
  end
  
  def kind ()
    @kind
  end
  
  def text ()
    @text
  end

  def children ()
    @zchildren
  end

  def child (n = 0)
    @zchildren[n]
  end

  def leftChild ()
    @zchildren[0]
  end

  def rightChild ()
    @zchildren[1]
  end

  def count ()
    @zchildren.size
  end

  def addChild (node)
    @zchildren.push(node)
  end

  def setAttribute (name, value)
    @attributes[name] = value
  end

  def getAttribute (name)
    @attributes[name]
  end

end

