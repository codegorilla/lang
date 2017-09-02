class Instruction

  def initialize (kind, text = nil)
    @kind = kind
    @text = text
  end

  def kind ()
    @kind
  end

  def setText (text)
    @text = text
  end

  def text ()
    @text
  end

end #class