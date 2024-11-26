# typed: true
# frozen_string_literal: true

module RubyJsonParser
  class Token
    extend T::Sig

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
      "Token(#{type.inspect}, #{value.inspect})"
    end

    END_OF_FILE = :end_of_file
    ERROR = :error
    LBRACKET = :lbracket
    RBRACKET = :rbracket
    LBRACE = :lbrace
    RBRACE = :rbrace
    COMMA = :comma
    COLON = :colon
    DOT = :dot
    NUMBER = :number
    STRING = :string
    FALSE = :false
    TRUE = :true
    NULL = :null

    DIGITS = '0123456789'
    HEX_DIGITS = '0123456789abcdefABCDEF'

    KEYWORDS = T.let(
      Set[
        FALSE.to_s,
        TRUE.to_s,
        NULL.to_s,
      ],
      T::Set[String]
    )
  end
end
