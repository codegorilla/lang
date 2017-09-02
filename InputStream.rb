class InputStream

  def initialize (filename)
    @filename = filename
    @pos = -1
  end

  def load ()
    @source = File.new(@filename, 'r')
    @buffer = @source.read
    @source.close
  end

  def consume ()
    @pos += 1
  end
  
  def index ()
    @pos + 1
  end

  def lookahead ()
    @buffer[@pos + 1]
  end  
  
end

