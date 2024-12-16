# typed: strict
# frozen_string_literal: true

require_relative 'token'

module RubyJsonParser
  # Color highlighter for JSON. Uses ANSI escape codes.
  module Highlighter
    class << self
      extend T::Sig

      sig { params(source: String).returns(String) }
      def highlight(source)
        lexer = Lexer.new(source)
        buff = String.new

        previous_end = 0
        lexer.each do |token|
          span = token.span
          between_lexemes = T.must source[previous_end...span.start.char_index]
          buff << between_lexemes if between_lexemes.length > 0

          lexeme_range = span.start.char_index..span.end.char_index
          lexeme = T.must source[lexeme_range]
          styles = token_styles(token)
          buff << ANSICodes.style(lexeme, styles)
          previous_end = span.end.char_index + 1
        end

        buff
      end

      private

      sig { params(token: Token).returns(T::Array[String]) }
      def token_styles(token)
        case token.type
        when Token::NULL, Token::FALSE, Token::TRUE
          [ANSICodes::FOREGROUND_GREEN, ANSICodes::ITALIC]
        when Token::COLON, Token::COMMA
          [ANSICodes::FOREGROUND_MAGENTA]
        when Token::LBRACE, Token::RBRACE, Token::LBRACKET, Token::RBRACKET
          [ANSICodes::FOREGROUND_BRIGHT_MAGENTA]
        when Token::NUMBER
          [ANSICodes::FOREGROUND_BRIGHT_BLUE]
        when Token::STRING
          [ANSICodes::FOREGROUND_BRIGHT_YELLOW]
        when Token::ERROR
          [ANSICodes.rgb_background(153, 51, 255), ANSICodes::STRIKE, ANSICodes::FOREGROUND_BLACK]
        else
          []
        end
      end

    end
  end
end
