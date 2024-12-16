# typed: true
# frozen_string_literal: true

require 'test_helper'

module RubyJsonParser
  class LexerTest < TestCase
    def test_lex
      expected = [
        Token.new(Token::LBRACE, S(P(0), P(0))),
        Token.new(Token::STRING, S(P(2), P(8)), "foo\n"),
        Token.new(Token::COLON, S(P(9), P(9))),
        Token.new(Token::STRING, S(P(11), P(17)), "ba\rr"),
        Token.new(Token::COMMA, S(P(18), P(18))),
        Token.new(Token::STRING, S(P(20), P(30)), "elo\uffe9"),
        Token.new(Token::COLON, S(P(31), P(31))),
        Token.new(Token::LBRACKET, S(P(33), P(33))),
        Token.new(Token::NUMBER, S(P(34), P(35)), '-1'),
        Token.new(Token::COMMA, S(P(36), P(36))),
        Token.new(Token::NUMBER, S(P(38), P(41)), '0.25'),
        Token.new(Token::COMMA, S(P(42), P(42))),
        Token.new(Token::NUMBER, S(P(44), P(46)), '5e9'),
        Token.new(Token::COMMA, S(P(47), P(47))),
        Token.new(Token::NUMBER, S(P(49), P(53)), '5e-20'),
        Token.new(Token::COMMA, S(P(54), P(54))),
        Token.new(Token::NUMBER, S(P(56), P(60)), '14e+9'),
        Token.new(Token::COMMA, S(P(61), P(61))),
        Token.new(Token::FALSE, S(P(63), P(67))),
        Token.new(Token::COMMA, S(P(68), P(68))),
        Token.new(Token::TRUE, S(P(70), P(73))),
        Token.new(Token::COMMA, S(P(74), P(74))),
        Token.new(Token::NULL, S(P(76), P(79))),
        Token.new(Token::RBRACKET, S(P(80), P(80))),
        Token.new(Token::RBRACE, S(P(82), P(82))),
      ]
      assert_equal expected, lex('{ "foo\n": "ba\rr", "elo\uffe9": [-1, 0.25, 5e9, 5e-20, 14e+9, false, true, null] }')

      expected = [
        Token.new(Token::NUMBER, S(P(0), P(2)), '123'),
      ]
      assert_equal expected, lex('123')

      expected = [
        Token.new(Token::ERROR, S(P(0), P(3)), 'unterminated string literal'),
      ]
      assert_equal expected, lex('"foo')

      expected = [
        Token.new(Token::ERROR, S(P(0), P(9)), 'invalid escape `\g`'),
        Token.new(Token::NUMBER, S(P(11), P(13)), '123'),
      ]
      assert_equal expected, lex('"lol\gelo" 123')

      expected = [
        Token.new(Token::ERROR, S(P(0), P(10)), 'invalid unicode escape'),
        Token.new(Token::NUMBER, S(P(12), P(14)), '123'),
      ]
      assert_equal expected, lex('"lol\ugego" 123')

      expected = [
        Token.new(Token::ERROR, S(P(0), P(10)), 'unexpected identifier: `fdg1234fsdf`'),
        Token.new(Token::COMMA, S(P(11), P(11))),
        Token.new(Token::NUMBER, S(P(13), P(15)), '123'),
      ]
      assert_equal expected, lex('fdg1234fsdf, 123')

      expected = [
        Token.new(Token::ERROR, S(P(0), P(10)), 'unexpected identifier: `fdg1234fsdf`'),
      ]
      assert_equal expected, lex('fdg1234fsdf')

      expected = [
        Token.new(Token::NUMBER, S(P(0), P(2)), '123'),
        Token.new(Token::ERROR, S(P(3), P(5)), 'unexpected identifier: `fge`'),
      ]
      assert_equal expected, lex('123fge')

      expected = [
        Token.new(Token::NUMBER, S(P(0), P(6)), '123.985'),
      ]
      assert_equal expected, lex('123.985')

      expected = [
        Token.new(Token::NUMBER, S(P(0), P(0)), '0'),
      ]
      assert_equal expected, lex('0')

      expected = [
        Token.new(Token::ERROR, S(P(0), P(4)), 'illegal trailing zero in number literal'),
        Token.new(Token::STRING, S(P(6), P(10)), 'lol'),
      ]
      assert_equal expected, lex('05812 "lol"')

      expected = [
        Token.new(Token::NUMBER, S(P(0), P(3)), '0.12'),
      ]
      assert_equal expected, lex('0.12')

      expected = [
        Token.new(Token::NUMBER, S(P(0), P(2)), '5e9'),
      ]
      assert_equal expected, lex('5e9')

      expected = [
        Token.new(Token::NUMBER, S(P(0), P(2)), '5E9'),
      ]
      assert_equal expected, lex('5E9')

      expected = [
        Token.new(Token::NUMBER, S(P(0), P(3)), '5e+9'),
      ]
      assert_equal expected, lex('5e+9')

      expected = [
        Token.new(Token::NUMBER, S(P(0), P(3)), '5e-9'),
      ]
      assert_equal expected, lex('5e-9')

      expected = [
        Token.new(Token::NUMBER, S(P(0), P(4)), '1.5e9'),
      ]
      assert_equal expected, lex('1.5e9')

      expected = [
        Token.new(Token::NUMBER, S(P(0), P(5)), '1.5e+9'),
      ]
      assert_equal expected, lex('1.5e+9')

      expected = [
        Token.new(Token::NUMBER, S(P(0), P(5)), '1.5e-9'),
      ]
      assert_equal expected, lex('1.5e-9')
    end

    private

    def lex(source)
      Lexer.new(source).to_a
    end
  end
end
