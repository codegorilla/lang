require './Token'
require './KeywordTable'

# The lexer class takes input from an input stream and creates a token stream

class Lexer

  STATE_START = 0
  STATE_IDENTIFIER = 1
  STATE_NUMBER = 2
  STATE_FLOAT = 3
  STATE_COMMENT = 4
  STATE_BLOCK_COMMENT = 5

  TILDE = '~'
  BANG = '!'
  AT = '@'
  POUND = '#'
  DOLLAR = '$'
  PERCENT = '%'
  CARET = '^'
  AMPERSAND = '&'
  ASTERISK = '*'
  MINUS = '-'
  PLUS = '+'
  EQUALS = '='

  L_PAREN = '('
  R_PAREN = ')'
  L_BRACKET = '['
  R_BRACKET = ']'
  L_BRACE = '{'
  R_BRACE = '}'

  SEMICOLON = ';'
  COLON = ':'
  COMMA = ','
  DOT = '.'
  SLASH = '/'

  L_ANGLE = '<'
  R_ANGLE = '>'

  EQUAL = '=='
  NOT_EQUAL = '!='
  GT_OR_EQUAL = '>='
  LT_OR_EQUAL = '<='

  AND = '&&'
  OR = '||'

  L_SHIFT = '<<'
  R_SHIFT = '>>'

  EOF = 'EOF'
  ERROR = 'ERROR'

  def initialize (inputStream)
    @is = inputStream
    @is.load
    @kt = KeywordTable.new

    @line = 1
    @column = 1

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @logger.info("Initialized lexer.")
  end
  
  def nextChar ()
    @is.lookahead
  end

  def consume ()
    @is.consume
    @column += 1
  end

  def line ()
    @line
  end

  def column ()
    @column
  end

  def makeToken (kind, text)
    t = Token.new(kind, text, line, column-1)
    return t
  end

  def getToken ()
    done = false
    state = STATE_START
    @logger.debug("Starting scan.")
    
    while (!done)
      case state
      when STATE_START
        ch = nextChar
        case ch

        when ' '
          # skip spaces
          consume

        when "\n"
          # skip newlines
          consume
          @line += 1
          @column = 1

        when nil
          # end of input
          consume
          token = makeToken(EOF, EOF)
          done = true

        when '~'
          consume
          token = makeToken(TILDE, TILDE)
          done = true

        when '!'
          consume
          if nextChar == '='
            consume
            token = makeToken(NOT_EQUAL, NOT_EQUAL)
          else
            token = makeToken(BANG, BANG)
          end
          done = true
        
        when '$'
          consume
          token = makeToken(DOLLAR, DOLLAR)
          done = true

        when '%'
          consume
          token = makeToken(PERCENT, PERCENT)
          done = true
        
        when '^'
          consume
          token = makeToken(CARET, CARET)
          done = true

        when '&'
          consume
          if nextChar == '&'
            consume
            token = makeToken(AND, AND)
          else
            token = makeToken(AMPERSAND, AMPERSAND)
          end
          done = true

        when '*'
          consume
          token = makeToken(ASTERISK, ASTERISK)
          done = true

        when '-'
          consume
          token = makeToken(MINUS, MINUS)
          done = true

        when '+'
          consume
          token = makeToken(PLUS, PLUS)
          done = true
        
        when '='
          consume
          if nextChar == '='
            consume
            @logger.debug("Found '=='")
            token = makeToken(EQUAL, EQUAL)
          else
            @logger.debug("(Ln #{line}, Col #{column-1}): Found '='")
            token = makeToken(EQUALS, EQUALS)
          end
          done = true

        when '|'
          consume
          if nextChar == '|'
            consume
            token = makeToken(OR, OR)
          else
            token = makeToken(PIPE, PIPE)
          end
          done = true

        when '('
          consume
          if nextChar == ')'
            consume
            # Maybe make this kind :UNIT
            token = makeToken('()', "()")
          else
            @logger.debug("Found '('")
            token = makeToken(L_PAREN, L_PAREN)
          end
          done = true
          
        when ')'
          @logger.debug("Found ')'")
          consume
          token = makeToken(R_PAREN, R_PAREN)
          done = true

        when '['
          @logger.debug("Found '['")
          consume
          token = makeToken(L_BRACKET, L_BRACKET)
          done = true

        when ']'
          @logger.debug("Found ']'")
          consume
          token = makeToken(R_BRACKET, R_BRACKET)
          done = true

        when '{'
          @logger.debug("Found '{'")
          consume
          token = makeToken(L_BRACE, L_BRACE)
          done = true

        when '}'
          @logger.debug("Found '}'")
          consume
          token = makeToken(R_BRACE, R_BRACE)
          done = true
        
        when ';'
          consume
          @logger.debug("(Ln #{line}, Col #{column-1}): Found ';'")
          token = makeToken(SEMICOLON, SEMICOLON)
          done = true

        when ':'
          @logger.debug("Found ':'")
          consume
          token = makeToken(COLON, COLON)
          done = true

        when ','
          @logger.debug("Found ','")
          consume
          token = makeToken(COMMA, COMMA)
          done = true
          
        when '.'
          @logger.debug("Found '.'")
          consume
          token = makeToken(DOT, DOT)
          done = true

        when '/'
          consume
          ch = nextChar
          if ch == '/'
            consume
            state = STATE_COMMENT
          elsif ch == '*'
            consume
            state = STATE_BLOCK_COMMENT
          else
            token = makeToken(SLASH, SLASH)
            done = true
          end

        when '<'
          consume
          ch = nextChar
          if ch == '<'
            consume
            token = makeToken(L_SHIFT, L_SHIFT)
          elsif ch == '='
            consume
            token = makeToken(LT_OR_EQUAL, LT_OR_EQUAL)
          else
            token = makeToken(L_ANGLE, L_ANGLE)
          end
          done = true

        when '>'
          consume
          ch = nextChar
          if ch == '>'
            consume
            token = makeToken(R_SHIFT, R_SHIFT)
          elsif ch == '='
            consume
            token = makeToken(GT_OR_EQUAL, GT_OR_EQUAL)
          else
            token = makeToken(R_ANGLE, R_ANGLE)
          end
          done = true

        else
          if ch.match(/[A-Za-z_]/)
            consume
            text = ch
            state = STATE_IDENTIFIER
            @logger.debug("Switched to identifier state.")
          elsif ch.match(/[0-9]/)
            consume
            text = ch
            state = STATE_NUMBER
            @logger.debug("Switched to number state.")
          elsif ch.match(/[.]/)
            # FIX: This will never be reached
            # Not all periods are beginning of floats
            consume
            text = ch
            state = STATE_FLOAT
            @logger.debug("Switched to float state.")
          else
            consume
            token = makeToken(ERROR, ERROR)
            done = true
          end
        end

      when STATE_COMMENT
        ch = nextChar
        while (ch != "\n")
          consume
          ch = nextChar
        end
        consume
        @line += 1
        state = STATE_START

      when STATE_IDENTIFIER
        ch = nextChar
        if ch.match(/[A-Za-z0-9_]/)
          consume
          text << ch
        else
          # Check if it is a keyword first
          t = @kt.lookup(text)
          token = if t
            makeToken(t.kind, t.text)
          else
            makeToken(:IDENTIFIER, text)
          end
          done = true
        end
        
      when STATE_NUMBER
        ch = nextChar
        if ch.match(/[0-9]/)
          consume
          text << ch
        elsif ch.match(/[.]/)
          consume
          text << ch
          state = STATE_FLOAT
        elsif ch == 'j'
          consume
          text << ch
          token = makeToken(:IMAGINARY, text)
          done = true
        else
          @logger.debug("(Ln #{line}, Col #{column-1}): Found integer '#{text}'")
          token = makeToken(:INTEGER, text)
          done = true
        end

      when STATE_FLOAT
        ch = nextChar
        if ch.match(/[0-9]/)
          consume
          text << ch
        else
          token = makeToken(:FLOAT, text)
          done = true
        end
        
      end
    end

    token
  end

end

