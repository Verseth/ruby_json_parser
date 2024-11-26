# typed: true
# frozen_string_literal: true

require_relative 'token'

module RubyJsonParser
  class Lexer
    extend T::Sig
    include Enumerable

    sig { params(source_name: String, source: String).void }
    def initialize(source_name, source)
      @source_name = source_name
      @source = source

      # offset of the first character of the current lexeme
      @start_cursor = T.let(0, Integer)
      # offset of the next character
      @cursor = T.let(0, Integer)
    end

    sig { returns(Token) }
    def next
      return Token.new(:end_of_file) unless has_more_tokens?

      scan_token
    end

    sig { override.params(block: T.nilable(T.proc.params(arg0: Token).void)).returns(T.untyped) }
    def each(&block)
      return enum_for(T.must(__method__)) unless block

      while true
        tok = self.next
        break if tok.type == Token::END_OF_FILE

        block.call(tok)
      end

      self
    end

    private

    sig { returns(T::Boolean) }
    def has_more_tokens?
      @cursor < @source.length
    end

    sig { params(type: Symbol).returns(Token) }
    def token_with_consumed_value(type)
      token(type, token_value)
    end

    sig { params(type: Symbol, value: T.nilable(String)).returns(Token) }
    def token(type, value = nil)
      @start_cursor = @cursor
      Token.new(type, value)
    end

    # Returns the current token value.
    def token_value
      @source[@start_cursor...@cursor]
    end

    sig { returns([String, T::Boolean]) }
    def advance_char
      return '', false unless has_more_tokens?

      char = next_char

      @cursor += 1
      [char, true]
    end

    sig { returns(String) }
    def next_char
      T.must @source[@cursor]
    end

    # Gets the next UTF-8 encoded character
    # without incrementing the cursor.
    sig { returns(String) }
    def peek_char
      return '' unless has_more_tokens?

      char, = next_char
      char
    end

    # Advance the next `n` characters
    sig { params(n: Integer).returns(T::Boolean) }
    def advance_chars(n)
      n.times do
        _, ok = advance_char
        return false unless ok
      end

      true
    end

    # Checks if the given character matches
    # the next UTF-8 encoded character in source code.
    # If they match, the cursor gets incremented.
    def match_char(char)
      return false unless has_more_tokens?

      if peek_char == char
        advance_char
        return true
      end

      false
    end

    # Consumes the next character if it's from the valid set.
    sig { params(valid_chars: String).returns(T::Boolean) }
    def match_chars(valid_chars)
      return false unless has_more_tokens?

      if valid_chars.include?(peek_char)
        advance_char
        return true
      end

      false
    end

    # Rewinds the cursor back n chars.
    sig { params(n: Integer).void }
    def backup_chars(n)
      @cursor -= n
    end

    # Skips the current accumulated token.
    sig { void }
    def skip_token
      @start_cursor = @cursor
    end

    sig { returns(Token) }
    def scan_token
      while true
        char, ok = advance_char
        return token(Token::END_OF_FILE) unless ok

        case char
        when '['
          return token(Token::LBRACKET)
        when ']'
          return token(Token::RBRACKET)
        when '{'
          return token(Token::LBRACE)
        when '}'
          return token(Token::RBRACE)
        when ','
          return token(Token::COMMA)
        when ':'
          return token(Token::COLON)
        when '.'
          return token(Token::DOT)
        when '"'
          return scan_string
        when '-'
          char, = advance_char
          return scan_number(char)
        when ' ', "\n", "\r", "\t"
          skip_token
          next
        else
          if char.match?(/[[:alpha:]]/)
            return scan_identifier
          elsif char.match?(/\d/)
            return scan_number(char)
          end

          return token(Token::ERROR, "unexpected char #{char.inspect}")
        end
      end
    end

    sig { params(char: String).returns(T::Boolean) }
    def identifier_char?(char)
      char.match?(/[[:alpha:][:digit:]_]/)
    end

    sig { returns(Token) }
    def scan_identifier
      advance_char while identifier_char?(peek_char)

      value = token_value
      return token(value.to_sym) if Token::KEYWORDS.include?(value)

      token(Token::ERROR, "unexpected identifier: #{value.inspect}")
    end

    sig { void }
    def consume_digits
      while true
        break unless Token::DIGITS.include?(peek_char)

        _, ok = advance_char
        break unless ok
      end
    end

    # Checks if the next `n` characters are from the valid set.
    sig { params(valid_chars: String, n: Integer).returns(T::Boolean) }
    def accept_chars(valid_chars, n)
      i = 0
      result = T.let(true, T::Boolean)
      n.times do
        unless match_chars(valid_chars)
          result = false
          break
        end
      end

      backup_chars(n)

      result
    end

    sig { params(init_char: String).returns(Token) }
    def scan_number(init_char)
      if init_char == '0'
        p = peek_char
        unless p == '.'
          return token(
            Token::ERROR,
            "unexpected char in number literal: #{p.inspect}, expected '.'"
          )
        end
      end

      consume_digits

      if match_char('.')
        p = peek_char
        unless Token::DIGITS.include?(p)
          return token(
            Token::ERROR,
            "unexpected char in number literal: #{p.inspect}"
          )
        end

        consume_digits
      end

      if match_char('e') || match_char('E')
        match_char('+') || match_char('-')
        p = peek_char
        unless Token::DIGITS.include?(p)
          return token(
            Token::ERROR,
            "unexpected char in number literal: #{p.inspect}"
          )
        end
        consume_digits
      end

      token_with_consumed_value(Token::NUMBER)
    end

    sig { returns(Token) }
    def scan_string
      value_buffer = String.new
      while true
        char, ok = advance_char
        return token(Token::ERROR, 'unterminated string literal') unless ok
        return token(Token::STRING, value_buffer) if char == '"'

        if char != '\\'
          value_buffer << char
          next
        end

        char, ok = advance_char
        return token(Token::ERROR, 'unterminated string literal') unless ok

        case char
        when '"'
          value_buffer << '"'
        when '\\'
          value_buffer << '\\'
        when '/'
          value_buffer << '/'
        when 'b'
          value_buffer << "\b"
        when 'f'
          value_buffer << "\f"
        when 'n'
          value_buffer << "\n"
        when 'r'
          value_buffer << "\r"
        when 't'
          value_buffer << "\t"
        when 'u'
          return Token.new(Token::ERROR, 'invalid unicode escape') unless accept_chars(Token::HEX_DIGITS, 4)

          advance_chars(4)
          last4 = T.must @source[@cursor - 4...@cursor]
          value_buffer << last4.hex.chr('UTF-8')

        end
      end
    end
  end
end
