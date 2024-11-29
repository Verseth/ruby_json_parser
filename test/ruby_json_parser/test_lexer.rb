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

      expected = [
        Token.new(Token::NUMBER, '123')
      ]
      assert_equal expected, lex('123')

      expected = [
        Token.new(Token::ERROR, 'unterminated string literal')
      ]
      assert_equal expected, lex('"foo')

      expected = [
        Token.new(Token::ERROR, 'invalid escape \g'),
        Token.new(Token::NUMBER, '123')
      ]
      assert_equal expected, lex('"lol\gelo" 123')

      expected = [
        Token.new(Token::ERROR, 'invalid unicode escape'),
        Token.new(Token::NUMBER, '123')
      ]
      assert_equal expected, lex('"lol\ugego" 123')

      expected = [
        Token.new(Token::ERROR, 'unexpected identifier: "fdg1234fsdf"'),
        Token.new(Token::COMMA),
        Token.new(Token::NUMBER, '123')
      ]
      assert_equal expected, lex('fdg1234fsdf, 123')

      expected = [
        Token.new(Token::ERROR, 'unexpected identifier: "fdg1234fsdf"')
      ]
      assert_equal expected, lex('fdg1234fsdf')

      expected = [
        Token.new(Token::NUMBER, '123'),
        Token.new(Token::ERROR, 'unexpected identifier: "fge"')
      ]
      assert_equal expected, lex('123fge')

      expected = [
        Token.new(Token::NUMBER, '123.985')
      ]
      assert_equal expected, lex('123.985')

      expected = [
        Token.new(Token::NUMBER, '0')
      ]
      assert_equal expected, lex('0')

      expected = [
        Token.new(Token::ERROR, "unexpected char in number literal: \"5\", expected '.'"),
        Token.new(Token::STRING, 'lol')
      ]
      assert_equal expected, lex('05812 "lol"')

      expected = [
        Token.new(Token::NUMBER, '0.12')
      ]
      assert_equal expected, lex('0.12')

      expected = [
        Token.new(Token::NUMBER, '5e9')
      ]
      assert_equal expected, lex('5e9')

      expected = [
        Token.new(Token::NUMBER, '5E9')
      ]
      assert_equal expected, lex('5E9')

      expected = [
        Token.new(Token::NUMBER, '5e+9')
      ]
      assert_equal expected, lex('5e+9')

      expected = [
        Token.new(Token::NUMBER, '5e-9')
      ]
      assert_equal expected, lex('5e-9')

      expected = [
        Token.new(Token::NUMBER, '1.5e9')
      ]
      assert_equal expected, lex('1.5e9')

      expected = [
        Token.new(Token::NUMBER, '1.5e+9')
      ]
      assert_equal expected, lex('1.5e+9')

      expected = [
        Token.new(Token::NUMBER, '1.5e-9')
      ]
      assert_equal expected, lex('1.5e-9')
    end

    private

    def lex(source)
      Lexer.new('<json>', source).to_a
    end
  end
end
