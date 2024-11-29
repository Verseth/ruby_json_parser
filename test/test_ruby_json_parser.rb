# typed: true
# frozen_string_literal: true

require 'test_helper'

class TestRubyJsonParser < Minitest::Test
  extend T::Sig
  AST = RubyJsonParser::AST
  Token = RubyJsonParser::Token

  def test_that_it_has_a_version_number
    refute_nil ::RubyJsonParser::VERSION
  end

  def test_parse_accept
    parse_test(
      '"foo"',
      AST::StringLiteralNode.new('foo'),
    )

    parse_test(
      '["foo"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new('foo')],
      ),
    )

    parse_test(
      '[]',
      AST::ArrayLiteralNode.new([]),
    )

    parse_test(
      ' [] ',
      AST::ArrayLiteralNode.new([]),
    )

    parse_test(
      '[true]',
      AST::ArrayLiteralNode.new(
        [AST::TrueLiteralNode.new],
      ),
    )

    parse_test(
      "[\"a\"]\n",
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new('a')],
      ),
    )

    parse_test(
      '""',
      AST::StringLiteralNode.new(''),
    )

    parse_test(
      'true',
      AST::TrueLiteralNode.new,
    )

    parse_test(
      'false',
      AST::FalseLiteralNode.new,
    )

    parse_test(
      'null',
      AST::NullLiteralNode.new,
    )

    parse_test(
      '42',
      AST::NumberLiteralNode.new('42'),
    )

    parse_test(
      '-42',
      AST::NumberLiteralNode.new('-42'),
    )

    parse_test(
      '0',
      AST::NumberLiteralNode.new('0'),
    )

    parse_test(
      '-0',
      AST::NumberLiteralNode.new('-0'),
    )

    parse_test(
      '-0.1',
      AST::NumberLiteralNode.new('-0.1'),
    )

    parse_test(
      '123.456789',
      AST::NumberLiteralNode.new('123.456789'),
    )

    parse_test(
      '0e1',
      AST::NumberLiteralNode.new('0e1'),
    )

    parse_test(
      '1e+2',
      AST::NumberLiteralNode.new('1e+2'),
    )

    parse_test(
      '1E+2',
      AST::NumberLiteralNode.new('1E+2'),
    )

    parse_test(
      '1e-2',
      AST::NumberLiteralNode.new('1e-2'),
    )

    parse_test(
      '1E-2',
      AST::NumberLiteralNode.new('1E-2'),
    )

    parse_test(
      '123e45',
      AST::NumberLiteralNode.new('123e45'),
    )

    parse_test(
      '123E45',
      AST::NumberLiteralNode.new('123E45'),
    )

    parse_test(
      '123.456e78',
      AST::NumberLiteralNode.new('123.456e78'),
    )

    parse_test(
      '123.456E78',
      AST::NumberLiteralNode.new('123.456E78'),
    )

    parse_test(
      '123.456e+78',
      AST::NumberLiteralNode.new('123.456e+78'),
    )

    parse_test(
      '123.456E+78',
      AST::NumberLiteralNode.new('123.456E+78'),
    )

    parse_test(
      '123.456e-78',
      AST::NumberLiteralNode.new('123.456e-78'),
    )

    parse_test(
      '123.456E-78',
      AST::NumberLiteralNode.new('123.456E-78'),
    )

    parse_test(
      '[ 4]',
      AST::ArrayLiteralNode.new(
        [AST::NumberLiteralNode.new('4')],
      ),
    )

    parse_test(
      <<~JSON,
        [
          6
        ]

      JSON
      AST::ArrayLiteralNode.new(
        [AST::NumberLiteralNode.new('6')],
      ),
    )

    parse_test(
      '[1,null,null,null,2]',
      AST::ArrayLiteralNode.new(
        [
          AST::NumberLiteralNode.new('1'),
          AST::NullLiteralNode.new,
          AST::NullLiteralNode.new,
          AST::NullLiteralNode.new,
          AST::NumberLiteralNode.new('2'),
        ],
      ),
    )

    parse_test(
      '["aa"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("a\x7Fa")],
      ),
    )

    parse_test(
      '["€𝄞"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new('€𝄞')],
      ),
    )

    parse_test(
      '["\u0022"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("\u0022")],
      ),
    )

    parse_test(
      '["\uFFFE"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("\uFFFE")],
      ),
    )

    parse_test(
      '["\uFDD0"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("\uFDD0")],
      ),
    )

    parse_test(
      '["\u2064"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("\u2064")],
      ),
    )

    parse_test(
      '["\u200B"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("\u200B")],
      ),
    )

    parse_test(
      '["\uD83F\uDFFE"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("\xED\xA0\xBF\xED\xBF\xBE")],
      ),
    )

    parse_test(
      '["\uD83F\uDFFE"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("\xED\xA0\xBF\xED\xBF\xBE")],
      ),
    )

    parse_test(
      '["\uDBFF\uDFFE"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("\xED\xAF\xBF\xED\xBF\xBE")],
      ),
    )

    parse_test(
      '["⍂㈴⍂"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new('⍂㈴⍂')],
      ),
    )

    parse_test(
      '["\u005C"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("\u005C")],
      ),
    )

    parse_test(
      '[""]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("\x7F")],
      ),
    )

    parse_test(
      '["new\u000Aline"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("new\nline")],
      ),
    )

    parse_test(
      '["\u0061\u30af\u30EA\u30b9"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("\u0061\u30af\u30EA\u30b9")],
      ),
    )

    parse_test(
      '[" "]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new(' ')],
      ),
    )

    parse_test(
      '[" "]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new(' ')],
      ),
    )

    parse_test(
      '["\u002c"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("\u002c")],
      ),
    )

    parse_test(
      '["\u0123"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("\u0123")],
      ),
    )

    parse_test(
      '["\u0821"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new("\u0821")],
      ),
    )

    parse_test(
      '["𛿿"]',
      AST::ArrayLiteralNode.new(
        [AST::StringLiteralNode.new('𛿿')],
      ),
    )

    parse_test(
      '" "',
      AST::StringLiteralNode.new(' '),
    )

    parse_test(
      '"\""',
      AST::StringLiteralNode.new('"'),
    )

    parse_test(
      '"\r\b\n\t\f\"\\\\\\/"',
      AST::StringLiteralNode.new("\r\b\n\t\f\"\\/"),
    )

    parse_test(
      <<~JSON,
        {
          "a": "b"
        }
      JSON
      AST::ObjectLiteralNode.new(
        [
          AST::KeyValuePairNode.new(
            AST::StringLiteralNode.new('a'),
            AST::StringLiteralNode.new('b'),
          ),
        ],
      ),
    )

    parse_test(
      '{"a":[]}',
      AST::ObjectLiteralNode.new(
        [
          AST::KeyValuePairNode.new(
            AST::StringLiteralNode.new('a'),
            AST::ArrayLiteralNode.new([]),
          ),
        ],
      ),
    )

    parse_test(
      '{"x":[{"id": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}], "id": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}',
      AST::ObjectLiteralNode.new(
        [
          AST::KeyValuePairNode.new(
            AST::StringLiteralNode.new('x'),
            AST::ArrayLiteralNode.new(
              [
                AST::ObjectLiteralNode.new(
                  [
                    AST::KeyValuePairNode.new(
                      AST::StringLiteralNode.new('id'),
                      AST::StringLiteralNode.new('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AST::KeyValuePairNode.new(
            AST::StringLiteralNode.new('id'),
            AST::StringLiteralNode.new('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'),
          ),
        ],
      ),
    )

    parse_test(
      '{ "min": -1.0e+28, "max": 1.0e+28 }',
      AST::ObjectLiteralNode.new(
        [
          AST::KeyValuePairNode.new(
            AST::StringLiteralNode.new('min'),
            AST::NumberLiteralNode.new('-1.0e+28'),
          ),
          AST::KeyValuePairNode.new(
            AST::StringLiteralNode.new('max'),
            AST::NumberLiteralNode.new('1.0e+28'),
          ),
        ],
      ),
    )

    parse_test(
      '{"foo\u0000bar": 42}',
      AST::ObjectLiteralNode.new(
        [
          AST::KeyValuePairNode.new(
            AST::StringLiteralNode.new("foo\u0000bar"),
            AST::NumberLiteralNode.new('42'),
          ),
        ],
      ),
    )

    parse_test(
      '{"":0}',
      AST::ObjectLiteralNode.new(
        [
          AST::KeyValuePairNode.new(
            AST::StringLiteralNode.new(''),
            AST::NumberLiteralNode.new('0'),
          ),
        ],
      ),
    )

    parse_test(
      '{"foo": 42, "foo": null}',
      AST::ObjectLiteralNode.new(
        [
          AST::KeyValuePairNode.new(
            AST::StringLiteralNode.new('foo'),
            AST::NumberLiteralNode.new('42'),
          ),
          AST::KeyValuePairNode.new(
            AST::StringLiteralNode.new('foo'),
            AST::NullLiteralNode.new,
          ),
        ],
      ),
    )

    parse_test(
      '{}',
      AST::ObjectLiteralNode.new([]),
    )
  end

  def test_parse_reject
    parse_test(
      '.12',
      AST::InvalidNode.new(Token.new(Token::DOT)),
      ['unexpected token `.`'],
    )

    parse_test(
      '1.',
      AST::InvalidNode.new(Token.new(Token::ERROR, 'unexpected EOF')),
      ['unexpected EOF'],
    )

    parse_test(
      '012',
      AST::InvalidNode.new(Token.new(Token::ERROR, 'illegal trailing zero in number literal')),
      ['illegal trailing zero in number literal'],
    )

    parse_test(
      '- 1',
      AST::InvalidNode.new(Token.new(Token::ERROR, 'unexpected number char: ` `')),
      ['unexpected number char: ` `'],
    )

    parse_test(
      '+1',
      AST::InvalidNode.new(Token.new(Token::ERROR, 'unexpected char `+`')),
      ['unexpected char `+`'],
    )

    parse_test(
      '[1, 2,]',
      AST::ArrayLiteralNode.new(
        [
          AST::NumberLiteralNode.new('1'),
          AST::NumberLiteralNode.new('2'),
        ],
      ),
      ['illegal trailing comma in array literal'],
    )

    parse_test(
      '[1, 2',
      AST::ArrayLiteralNode.new(
        [
          AST::NumberLiteralNode.new('1'),
          AST::NumberLiteralNode.new('2'),
        ],
      ),
      ['unexpected `END_OF_FILE`, expected `]`'],
    )

    parse_test(
      '{ "foo": 1, 2 }',
      AST::ObjectLiteralNode.new(
        [
          AST::KeyValuePairNode.new(
            AST::StringLiteralNode.new('foo'),
            AST::NumberLiteralNode.new('1'),
          ),
          AST::KeyValuePairNode.new(
            nil,
            AST::NumberLiteralNode.new('2'),
          ),
        ],
      ),
      ['missing key in object literal for value: `2`'],
    )

    parse_test(
      '{ "foo": 1, }',
      AST::ObjectLiteralNode.new(
        [
          AST::KeyValuePairNode.new(
            AST::StringLiteralNode.new('foo'),
            AST::NumberLiteralNode.new('1'),
          ),
        ],
      ),
      ['illegal trailing comma in object literal'],
    )

    parse_test(
      '{ "foo": 1',
      AST::ObjectLiteralNode.new(
        [
          AST::KeyValuePairNode.new(
            AST::StringLiteralNode.new('foo'),
            AST::NumberLiteralNode.new('1'),
          ),
        ],
      ),
      ['unexpected `END_OF_FILE`, expected `}`'],
    )
  end

  private

  sig do
    params(input: String, ast: AST::Node, errors: T::Array[String]).void
  end
  def parse_test(input, ast, errors = [])
    result = parse(input)
    assert_equal ast, result.ast
    assert_equal errors, result.errors
  end

  sig { params(source: String).returns(RubyJsonParser::Result) }
  def parse(source)
    RubyJsonParser.parse(source)
  end
end
