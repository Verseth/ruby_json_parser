# frozen_string_literal: true

require 'test_helper'

module RubyJsonParser
  class TestLexer < Minitest::Test
    def test_lex
      expected = [
        Token.new(Token::LBRACE),
        Token.new(Token::STRING, "foo\n"),
        Token.new(Token::COLON),
        Token.new(Token::STRING, "ba\rr"),
        Token.new(Token::COMMA),
        Token.new(Token::STRING, "elo\uffe9"),
        Token.new(Token::COLON),
        Token.new(Token::LBRACKET),
        Token.new(Token::NUMBER, '-1'),
        Token.new(Token::COMMA),
        Token.new(Token::NUMBER, '0.25'),
        Token.new(Token::COMMA),
        Token.new(Token::NUMBER, '5e9'),
        Token.new(Token::COMMA),
        Token.new(Token::NUMBER, '5e-20'),
        Token.new(Token::COMMA),
        Token.new(Token::NUMBER, '14e+9'),
        Token.new(Token::COMMA),
        Token.new(Token::FALSE),
        Token.new(Token::COMMA),
        Token.new(Token::TRUE),
        Token.new(Token::COMMA),
        Token.new(Token::NULL),
        Token.new(Token::RBRACKET),
        Token.new(Token::RBRACE)
      ]
      assert_equal expected, lex('{ "foo\n": "ba\rr", "elo\uffe9": [-1, 0.25, 5e9, 5e-20, 14e+9, false, true, null] }')
    end

    private

    def lex(source)
      Lexer.new('<json>', source).to_a
    end
  end
end
