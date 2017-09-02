require './Token'

class KeywordTable

  # Some pre-defined dummy tokens to clone fronm?
  BREAK = Token.new('break', "break")
  CLASS = Token.new('class', "class")
  CONTINUE = Token.new('continue', "continue")
  DEF = Token.new('def', "def")
  DO = Token.new('do', "do")
  ELSE = Token.new('else', "else")
  EXTENDS = Token.new('extends', "extends")
  FALSE = Token.new(:BOOLEAN, "false")
  FOR = Token.new('for', "for")
  FUN = Token.new('fun', "fun")
  IF = Token.new('if', "if")
  IMPORT = Token.new('import', "import")
  NEW = Token.new('new', "new")
  NIL = Token.new('nil', "nil")
  RETURN = Token.new('return', "return")
  SUPER = Token.new('super', "super")
  THIS = Token.new('this', "this")
  TRUE = Token.new(:BOOLEAN, "true")
  VAL = Token.new('val', "val")
  VAR = Token.new('var', "var")
  WHILE = Token.new('while', "while")

  # Other future keywords?
  # CASE
  # CONST
  # IS
  # MATCH
  # MODULE
  # MY
  # SWITCH
  # WITH
  # YIELD

  def initialize ()
    @table = {
      'break' => BREAK,
      'class' => CLASS,
      'continue' => CONTINUE,
      'def' => DEF,
      'do' => DO,
      'else' => ELSE,
      'extends' => EXTENDS,
      'false' => FALSE,
      'for' => FOR,
      'fun' => FUN,
      'if' => IF,
      'import' => IMPORT,
      'new' => NEW,
      'nil' => NIL,
      'return' => RETURN,
      'super' => SUPER,
      'this' => THIS,
      'true' => TRUE,
      'val' => VAL,
      'var' => VAR,
      'while' => WHILE,
    }
  end
  
  def insert (keyword, token)
    @table[keyword] = token
  end

  def lookup (keyword)
    @table[keyword]
  end

  def table
    @table
  end
  
end

