class TauObject

  def initialize (type = nil, value = nil)
    @type = type
    @value = value

    @members = {}
  end

  def setType (type)
    @type = type
  end

  def type ()
    @type
  end

  def setValue (value)
    @value = value
  end

  def value ()
    @value
  end

  def setMember (name, value)
    @members[name] = value
  end

  def getMember (name)
    @members[name]
  end

end

