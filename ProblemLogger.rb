class ProblemLogger

  def initialize ()
    @errors = []
    @warnings = []
    
    @errorCount = 0
    @warningCount = 0
  end

  def errors ()
    @errors
  end

  def warnings ()
    @warnings
  end

  def errorCount ()
    @errorCount
  end

  def warningCount ()
    @warningCount
  end

  def error (message, line = 0, column = 0)
    entry = "error: (Ln #{line}, Col #{column}) #{message}"
    @errors[@errorCount] = entry
    @errorCount += 1
  end

  def warning (message, line = 0, column = 0)
    entry = "warning: (Ln #{line}, Col #{column}) #{message}"
    @warnings[@warningCount] = entry
    @warningCount += 1
  end

end # class

