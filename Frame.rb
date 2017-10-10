class Frame

  def initialize (link = nil)
    @link = link
    @locals = {}
  end

  # Probably need to keep a table of variables here.
  # The table is a runtime table, so should be independent of scopes I think.
  # Runtime has no notion of declarations so it is ok to (re-)define multiple
  # times. Perhaps this should be called bind?
  def define (name, value)
    @locals[name] = value
  end

  def resolve (name)
    @locals[name]
  end
end

