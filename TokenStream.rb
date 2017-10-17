class TokenStream

  def initialize (source)
    @source = source
    @buffer = []
    fill
    @pos = -1
  end

  def fill ()
    more = fetch
    while more == true
      more = fetch
    end
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

  def consume ()
    @pos += 1
  end

  def index ()
    # Does this ever get used?
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

  def buffer ()
    # does anything ever need to get the buffer?
    @buffer
  end

end

