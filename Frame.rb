class Frame

  def initialize (dynamicLink = nil)
    @dynamicLink = dynamicLink
    @staticLink = nil
    @locals = {}
  end

  # Probably need to keep a table of variables here.
  # The table is a runtime table.
  # Need to take care of lexical scoping rules, which requires a "static link"
  # Runtime has no notion of declarations so it is ok to (re-)define multiple
  # times. Perhaps this should be called bind?
  def define (name, value)
    @locals[name] = value
  end

  def resolve (name)
    @locals[name]
  end
end

