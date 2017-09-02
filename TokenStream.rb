class TokenStream

  def initialize (source)
    @source = source
    @buffer = []
    @pos = -1
  end

  def fetch ()
    token = @source.getToken
    @buffer.push(token)

    if token.kind != 'EOF'
      true
    else
      false
    end
  end

  def fill ()
    more = fetch
    while more == true
      more = fetch
    end
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

  def get (i)
    @buffer[i]
  end

  def getText (i)
    @buffer[i].text
  end

  def source ()
    @source
  end
  
  def buffer ()
    @buffer
  end
  
end

