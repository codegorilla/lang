require './Token'
require './KeywordTable'

# The lexer class takes input from an input stream and creates a token stream

class Lexer

  STATE_START = 0
  STATE_IDENTIFIER = 1
  STATE_NUMBER = 2
  STATE_FLOAT = 3
  STATE_FLOAT1 = 4
  STATE_FLOAT2 = 5
  STATE_FLOAT3 = 6
  STATE_COMMENT = 7
  STATE_BLOCK_COMMENT = 8
  STATE_STRING = 9

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

  PLUS_EQUALS = '+='
  MINUS_EQUALS = '-='

  MUL_EQUALS = '*='
  DIV_EQUALS = '/='

  PIPE = '|'

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

  # How does this EOF relate to the token EOF?
  EOF = 'EOF'
  ERROR = 'ERROR'

  def initialize (input)
    @input = input
    @kt = KeywordTable.new

    @line = 1
    @column = 1
    @start = 1

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN
    @logger.info("Initialized lexer.")

    @plog = ProblemLogger.new
  end
  
  def nextChar ()
    @input.lookahead
  end

  def consume ()
    @input.consume
    @column += 1
  end

  def line ()
    @line
  end

  def column ()
    @column
  end

  def start ()
    @start
  end

  def makeToken (kind, text)
    t = Token.new(kind, text, line, column-1)
    return t
  end

  def setLogLevel (level)
    @logger.level = level
  end

  def problems ()
    @plog
  end

  def getToken ()
    done = false
    state = STATE_START
    #@logger.debug("Starting scan.")
    
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
          @logger.debug("(Ln #{line}, Col #{column-1}): Found '<EOF>'")
          token = makeToken(EOF, EOF)
          done = true

        when '~'
          consume
          @logger.debug("(Ln #{line}, Col #{column-1}): Found '~'")
          token = makeToken(TILDE, TILDE)
          done = true

        when '!'
          consume
          if nextChar == '='
            consume
            @logger.debug("(Ln #{line}, Col #{column-2}): Found '!='")
            token = makeToken(NOT_EQUAL, NOT_EQUAL)
          else
            @logger.debug("(Ln #{line}, Col #{column-1}): Found '!'")
            token = makeToken(BANG, BANG)
          end
          done = true
        
        when '$'
          consume
          @logger.debug("(Ln #{line}, Col #{column-1}): Found '$'")
          token = makeToken(DOLLAR, DOLLAR)
          done = true

        when '%'
          consume
          @logger.debug("(Ln #{line}, Col #{column-1}): Found '%'")
          token = makeToken(PERCENT, PERCENT)
          done = true
        
        when '^'
          consume
          @logger.debug("(Ln #{line}, Col #{column-1}): Found '^'")
          token = makeToken(CARET, CARET)
          done = true

        when '&'
          consume
          if nextChar == '&'
            consume
            @logger.debug("(Ln #{line}, Col #{column-2}): Found '&&'")
            token = makeToken(AND, AND)
          else
            @logger.debug("(Ln #{line}, Col #{column-1}): Found '&'")
            token = makeToken(AMPERSAND, AMPERSAND)
          end
          done = true

        when '*'
          consume
          if nextChar == '='
            consume
            @logger.debug("(Ln #{line}, Col #{column-2}): Found '*='")
            token = makeToken(MUL_EQUALS, MUL_EQUALS)
          else
            @logger.debug("(Ln #{line}, Col #{column-1}): Found '*'")
            token = makeToken(ASTERISK, ASTERISK)
          end
          done = true

        when '-'
          consume
          if nextChar == '='
            consume
            @logger.debug("(Ln #{line}, Col #{column-2}): Found '-='")
            token = makeToken(MINUS_EQUALS, MINUS_EQUALS)
          else
            @logger.debug("(Ln #{line}, Col #{column-1}): Found '-'")
            token = makeToken(MINUS, MINUS)
          end
          done = true

        when '+'
          consume
          if nextChar == '='
            consume
            @logger.debug("(Ln #{line}, Col #{column-2}): Found '+='")
            token = makeToken(PLUS_EQUALS, PLUS_EQUALS)
          else
            @logger.debug("(Ln #{line}, Col #{column-1}): Found '+'")
            token = makeToken(PLUS, PLUS)
          end
          done = true
        
        when '='
          consume
          if nextChar == '='
            consume
            @logger.debug("(Ln #{line}, Col #{column-2}): Found '=='")
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
            @logger.debug("(Ln #{line}, Col #{column-2}): Found '||'")
            token = makeToken(OR, OR)
          else
            @logger.debug("(Ln #{line}, Col #{column-1}): Found '|'")
            token = makeToken(PIPE, PIPE)
          end
          done = true

        when '('
          consume
          if nextChar == ')'
            consume
            @logger.debug("(Ln #{line}, Col #{column-2}): Found '()'")
            token = makeToken(:UNIT, "()")
          else
            @logger.debug("(Ln #{line}, Col #{column-1}): Found '('")
            token = makeToken(L_PAREN, L_PAREN)
          end
          done = true
          
        when ')'
          consume
          @logger.debug("(Ln #{line}, Col #{column-1}): Found ')'")
          token = makeToken(R_PAREN, R_PAREN)
          done = true

        when '['
          consume
          @logger.debug("(Ln #{line}, Col #{column-1}): Found '['")
          token = makeToken(L_BRACKET, L_BRACKET)
          done = true

        when ']'
          consume
          @logger.debug("(Ln #{line}, Col #{column-1}): Found ']'")
          token = makeToken(R_BRACKET, R_BRACKET)
          done = true

        when '{'
          consume
          @logger.debug("(Ln #{line}, Col #{column-1}): Found '{'")
          token = makeToken(L_BRACE, L_BRACE)
          done = true

        when '}'
          consume
          @logger.debug("(Ln #{line}, Col #{column-1}): Found '}'")
          token = makeToken(R_BRACE, R_BRACE)
          done = true
        
        when ';'
          consume
          @logger.debug("(Ln #{line}, Col #{column-1}): Found ';'")
          token = makeToken(SEMICOLON, SEMICOLON)
          done = true

        when ':'
          consume
          @logger.debug("(Ln #{line}, Col #{column-1}): Found ':'")
          token = makeToken(COLON, COLON)
          done = true

        when ','
          consume
          @logger.debug("(Ln #{line}, Col #{column-1}): Found ','")
          token = makeToken(COMMA, COMMA)
          done = true

        when '.'
          consume
          ch = nextChar
          if ch.match(/[0-9]/)
            consume
            text = ".#{ch}"
            state = STATE_FLOAT
          else
            @logger.debug("(Ln #{line}, Col #{column-1}): Found '.'")
            token = makeToken(DOT, DOT)
            done = true
          end

        when '/'
          consume
          ch = nextChar
          if ch == '/'
            consume
            # suppress logging comments
            #@logger.debug("(Ln #{line}, Col #{column-2}): Found comment")
            state = STATE_COMMENT
          elsif ch == '*'
            consume
            # suppress logging comments
            #@logger.debug("(Ln #{line}, Col #{column-2}): Found block comment")
            state = STATE_BLOCK_COMMENT
          elsif ch == '='
            consume
            @logger.debug("(Ln #{line}, Col #{column-2}): Found '/='")
            token = makeToken(DIV_EQUALS, DIV_EQUALS)
            done = true
          else
            @logger.debug("(Ln #{line}, Col #{column-1}): Found '/'")
            token = makeToken(SLASH, SLASH)
            done = true
          end

        when '<'
          consume
          ch = nextChar
          if ch == '<'
            consume
            @logger.debug("(Ln #{line}, Col #{column-2}): Found '<<'")
            token = makeToken(L_SHIFT, L_SHIFT)
          elsif ch == '='
            consume
            @logger.debug("(Ln #{line}, Col #{column-2}): Found '<='")
            token = makeToken(LT_OR_EQUAL, LT_OR_EQUAL)
          else
            @logger.debug("(Ln #{line}, Col #{column-1}): Found '<'")
            token = makeToken(L_ANGLE, L_ANGLE)
          end
          done = true

        when '>'
          consume
          ch = nextChar
          if ch == '>'
            consume
            @logger.debug("(Ln #{line}, Col #{column-2}): Found '>>'")
            token = makeToken(R_SHIFT, R_SHIFT)
          elsif ch == '='
            consume
            @logger.debug("(Ln #{line}, Col #{column-2}): Found '>='")
            token = makeToken(GT_OR_EQUAL, GT_OR_EQUAL)
          else
            @logger.debug("(Ln #{line}, Col #{column-1}): Found '>'")
            token = makeToken(R_ANGLE, R_ANGLE)
          end
          done = true
        
        when '"'
          consume
          text = ""
          state = STATE_STRING

        else
          if ch.match(/[A-Za-z_]/)
            consume
            @start = @column # mark start of pattern
            text = ch
            state = STATE_IDENTIFIER
            #@logger.debug("Switched to identifier state.")
          elsif ch.match(/[0-9]/)
            consume
            @start = @column # mark start of pattern
            text = ch
            state = STATE_NUMBER
            #@logger.debug("Switched to number state.")
          elsif ch.match(/[.]/)
            # FIX: This will never be reached
            # Not all periods are beginning of floats
            consume
            text = ch
            state = STATE_FLOAT
            #@logger.debug("Switched to float state.")
          else
            # Error recovery strategy for lexical errors:
            # Lexical errors are generally caused by invalid characters in the
            # input stream. Within the START state, if there are no valid
            # matches then you have a lexical error. The recovery strategy is to
            # simply throw away the invalid character and proceed as if nothing
            # was wrong. This means consuming the character and restarting the
            # scan in the same START state.
            # The other states don't have to worry about lexical errors because
            # if they encounter an invalid character then they simply don't
            # consume it, returning a token, and leaving the invalid character
            # to be found by the START state.
            # For now, it appears that all lexical errors can be recovered from
            # in this manner, so they don't prevent moving on to the parsing
            # stage. However, note that in order for the interpreter to run,
            # there must be no errors in any of the stages. Warnings are ok.
            # One issue with grouping by stages is that the list of errors that
            # are given to the user might be out of order, because all lexer
            # errors will be printed before parser errors, even if they occur
            # later in the input.
            consume
            @plog.error("character '#{ch}' not recognized", @line, @column-1)
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
          @logger.debug("(Ln #{line}, Col #{start-1}): Found keyword '#{t.text}'")
          makeToken(t.kind, t.text)
          else
            @logger.debug("(Ln #{line}, Col #{start-1}): Found identifier '#{text}'")
            makeToken(:ID, text)
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
        elsif ch.match(/(e|E)/)
          consume
          text << ch
          state = STATE_FLOAT1
        elsif ch == 'j'
          consume
          text << ch
          token = makeToken(:IMAGINARY, text)
          done = true
        else
          @logger.debug("(Ln #{line}, Col #{start-1}): Found integer '#{text}'")
          token = makeToken(:INTEGER, text)
          done = true
        end

      when STATE_FLOAT
        ch = nextChar
        if ch.match(/[0-9]/)
          consume
          text << ch
        elsif ch.match(/(e|E)/)
          consume
          text << ch
          state = STATE_FLOAT1
        else
          @logger.debug("(Ln #{line}, Col #{start-1}): Found float '#{text}'")
          token = makeToken(:FLOAT, text)
          done = true
        end

      when STATE_FLOAT1
        ch = nextChar
        if ch.match(/(-|\+)/)
          consume
          text << ch
          state = STATE_FLOAT2
        elsif ch.match(/[0-9]/)
          consume
          text << ch
          state = STATE_FLOAT3
        end
        # Needs to be an error if this doesn't move on to next state

      when STATE_FLOAT2
        ch = nextChar
        if ch.match(/[0-9]/)
          consume
          text << ch
          state = STATE_FLOAT3
        end
        # Needs to be an error if this doesn't move on to next state

      when STATE_FLOAT3
        ch = nextChar
        if ch.match(/[0-9]/)
          consume
          text << ch
        else
          @logger.debug("(Ln #{line}, Col #{start-1}): Found float '#{text}'")
          token = makeToken(:FLOAT, text)
          done = true
        end

      when STATE_STRING
        ch = nextChar
        while (ch != '"')
          consume
          text << ch
          ch = nextChar
        end
        consume
        # Need to adjust line and col, probably need to track line/col start
        @logger.debug("(Ln #{line}, Col #{start-1}): Found string '#{text}'")
        token = makeToken(:STRING, text)
        done = true

      end
    end

    token
  end

end # class

