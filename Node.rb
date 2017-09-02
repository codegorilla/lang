class Node

  def initialize (kind, text = nil)
    @kind = kind
    @text = text
    @zchildren = []
  end

  UNIT_LITERAL = Node.new(:UNIT_LITERAL, "()")

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

end

