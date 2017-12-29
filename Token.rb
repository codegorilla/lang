class Token

  def initialize (kind, text = nil, line = 0, column = 0)
    @kind = kind
    @text = text
    @line = line
    @column = column
  end

  EOF = Token.new(:EOF)
  UNKNOWN = Token.new(:UNKNOWN)

  def setText (text)
    @text = text
  end

  def kind ()
    @kind
  end
  
  def text ()
    @text
  end

  def line ()
    @line
  end

  def column ()
    @column
  end

end #class

