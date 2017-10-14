class InputStream

  def initialize (filename)
    # Read contents of file into buffer
    @file = File.new(filename, 'r')
    @buffer = @file.read
    @file.close
    @pos = -1
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
  
end # class

