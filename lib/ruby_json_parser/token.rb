# typed: strong
# frozen_string_literal: true

require 'set'

module RubyJsonParser
  # Represents a single token (word) produced by the lexer.
  class Token
    extend T::Sig

    class << self
      extend T::Sig

      # Converts a token type into a human-readable string.
      sig { params(type: Symbol).returns(String) }
      def type_to_string(type)
        case type
        when NONE
          'NONE'
        when END_OF_FILE
          'END_OF_FILE'
        when ERROR
          'ERROR'
        when LBRACKET
          '['
        when RBRACKET
          ']'
        when LBRACE
          '{'
        when RBRACE
          '}'
        when COMMA
          ','
        when COLON
          ':'
        when DOT
          '.'
        when NUMBER
          'NUMBER'
        when STRING
          'STRING'
        when false
          'false'
        when true
          'true'
        when NULL
          'null'
        else
          '<invalid>'
        end
      end
    end

    sig { returns(Symbol) }
    attr_reader :type

    sig { returns(T.nilable(String)) }
    attr_reader :value

    sig { params(type: Symbol, value: T.nilable(String)).void }
    def initialize(type, value = nil)
      @type = type
      @value = value
    end

    sig { params(other: Object).returns(T::Boolean) }
    def ==(other)
      return false unless other.is_a?(Token)

      type == other.type && value == other.value
    end

    sig { returns(String) }
    def inspect
      return "Token(#{type.inspect})" if value.nil?

      "Token(#{type.inspect}, #{value.inspect})"
    end

    # Converts a token into a human-readable string.
    sig { returns(String) }
    def to_s
      case type
      when NONE
        'NONE'
      when END_OF_FILE
        'END_OF_FILE'
      when ERROR
        "<error: #{value}>"
      when LBRACKET
        '['
      when RBRACKET
        ']'
      when LBRACE
        '{'
      when RBRACE
        '}'
      when COMMA
        ','
      when COLON
        ':'
      when DOT
        '.'
      when NUMBER
        value.to_s
      when STRING
        T.cast(value.inspect, String)
      when false
        'false'
      when true
        'true'
      when NULL
        'null'
      else
        '<invalid>'
      end
    end

    # String containing all valid decimal digits
    DIGITS = '0123456789'
    # String containing all valid hexadecimal digits
    HEX_DIGITS = '0123456789abcdefABCDEF'

    # Set of all JSON keywords
    KEYWORDS = T.let(
      Set[
        'false',
        'true',
        'null',
      ],
      T::Set[String],
    )


    # List of all token types
    # ------------------------

    # Represents no token, a placeholder
    NONE = :none
    # Signifies that the entire string/file has been processed,
    # there will be no more tokens
    END_OF_FILE = :end_of_file
    # Holds an error message, means that the string/file could not be
    # successfully processed
    ERROR = :error
    # Left bracket `[`
    LBRACKET = :lbracket
    # Right bracket `]`
    RBRACKET = :rbracket
    # Right brace `{`
    LBRACE = :lbrace
    # Left brace `}`
    RBRACE = :rbrace
    # Comma `,`
    COMMA = :comma
    # Colon `:`
    COLON = :colon
    # Dot `.`
    DOT = :dot
    # Number literal eg. `123`
    NUMBER = :number
    # String literal eg. `"foo"`
    STRING = :string
    # False literal `false`
    FALSE = :false
    # True literal `true`
    TRUE = :true
    # Null literal `null`
    NULL = :null
  end
end
