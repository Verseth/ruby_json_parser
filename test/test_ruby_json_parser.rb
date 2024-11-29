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
    result = parse('"foo"')
    expected_ast = AST::StringLiteralNode.new('foo')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('[]')
    expected_ast = AST::ArrayLiteralNode.new([])
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse(' [] ')
    expected_ast = AST::ArrayLiteralNode.new([])
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('[true]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::TrueLiteralNode.new],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse("[\"a\"]\n")
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new('a')],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors
    result = parse('""')
    expected_ast = AST::StringLiteralNode.new('')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('true')
    expected_ast = AST::TrueLiteralNode.new
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('false')
    expected_ast = AST::FalseLiteralNode.new
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('null')
    expected_ast = AST::NullLiteralNode.new
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('42')
    expected_ast = AST::NumberLiteralNode.new('42')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('-42')
    expected_ast = AST::NumberLiteralNode.new('-42')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('0')
    expected_ast = AST::NumberLiteralNode.new('0')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('-0')
    expected_ast = AST::NumberLiteralNode.new('-0')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('-0.1')
    expected_ast = AST::NumberLiteralNode.new('-0.1')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('123.456789')
    expected_ast = AST::NumberLiteralNode.new('123.456789')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('0e1')
    expected_ast = AST::NumberLiteralNode.new('0e1')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('1e+2')
    expected_ast = AST::NumberLiteralNode.new('1e+2')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('1E+2')
    expected_ast = AST::NumberLiteralNode.new('1E+2')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('1e-2')
    expected_ast = AST::NumberLiteralNode.new('1e-2')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('1E-2')
    expected_ast = AST::NumberLiteralNode.new('1E-2')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('123e45')
    expected_ast = AST::NumberLiteralNode.new('123e45')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('123E45')
    expected_ast = AST::NumberLiteralNode.new('123E45')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('123.456e78')
    expected_ast = AST::NumberLiteralNode.new('123.456e78')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('123.456E78')
    expected_ast = AST::NumberLiteralNode.new('123.456E78')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('123.456e+78')
    expected_ast = AST::NumberLiteralNode.new('123.456e+78')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('123.456E+78')
    expected_ast = AST::NumberLiteralNode.new('123.456E+78')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('123.456e-78')
    expected_ast = AST::NumberLiteralNode.new('123.456e-78')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('123.456E-78')
    expected_ast = AST::NumberLiteralNode.new('123.456E-78')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('[ 4]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::NumberLiteralNode.new('4')],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse(<<~JSON)
      [
        6
      ]
    JSON
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::NumberLiteralNode.new('6')],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('[1,null,null,null,2]')
    expected_ast = AST::ArrayLiteralNode.new(
      [
        AST::NumberLiteralNode.new('1'),
        AST::NullLiteralNode.new,
        AST::NullLiteralNode.new,
        AST::NullLiteralNode.new,
        AST::NumberLiteralNode.new('2'),
      ],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["aa"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("a\x7Fa")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["€𝄞"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new('€𝄞')],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["\u0022"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("\u0022")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["\uFFFE"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("\uFFFE")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["\uFDD0"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("\uFDD0")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["\u2064"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("\u2064")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["\u200B"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("\u200B")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["\uD83F\uDFFE"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("\xED\xA0\xBF\xED\xBF\xBE")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["\uD83F\uDFFE"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("\xED\xA0\xBF\xED\xBF\xBE")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["\uDBFF\uDFFE"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("\xED\xAF\xBF\xED\xBF\xBE")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["⍂㈴⍂"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new('⍂㈴⍂')],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["\u005C"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("\u005C")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('[""]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("\x7F")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["new\u000Aline"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("new\nline")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["\u0061\u30af\u30EA\u30b9"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("\u0061\u30af\u30EA\u30b9")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('[" "]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new(' ')],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('[" "]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new(' ')],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["\u002c"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("\u002c")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["\u0123"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("\u0123")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["\u0821"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new("\u0821")],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('["𛿿"]')
    expected_ast = AST::ArrayLiteralNode.new(
      [AST::StringLiteralNode.new('𛿿')],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('" "')
    expected_ast = AST::StringLiteralNode.new(' ')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('"\""')
    expected_ast = AST::StringLiteralNode.new('"')
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('"\r\b\n\t\f\"\\\\\\/"')
    expected_ast = AST::StringLiteralNode.new("\r\b\n\t\f\"\\/")
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse(<<~JSON)
      {
        "a": "b"
      }
    JSON
    expected_ast = AST::ObjectLiteralNode.new(
      [
        AST::KeyValuePairNode.new(
          AST::StringLiteralNode.new('a'),
          AST::StringLiteralNode.new('b'),
        ),
      ],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('{"a":[]}')
    expected_ast = AST::ObjectLiteralNode.new(
      [
        AST::KeyValuePairNode.new(
          AST::StringLiteralNode.new('a'),
          AST::ArrayLiteralNode.new([]),
        ),
      ],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse <<~JSON
      {
        "x": [
          {
            "id": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
          }
        ],
        "id": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      }
    JSON
    expected_ast = AST::ObjectLiteralNode.new(
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
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('{ "min": -1.0e+28, "max": 1.0e+28 }')
    expected_ast = AST::ObjectLiteralNode.new(
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
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('{"foo\u0000bar": 42}')
    expected_ast = AST::ObjectLiteralNode.new(
      [
        AST::KeyValuePairNode.new(
          AST::StringLiteralNode.new("foo\u0000bar"),
          AST::NumberLiteralNode.new('42'),
        ),
      ],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('{"":0}')
    expected_ast = AST::ObjectLiteralNode.new(
      [
        AST::KeyValuePairNode.new(
          AST::StringLiteralNode.new(''),
          AST::NumberLiteralNode.new('0'),
        ),
      ],
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('{"foo": 42, "foo": null}')
    expected_ast = AST::ObjectLiteralNode.new(
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
    )
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors

    result = parse('{}')
    expected_ast = AST::ObjectLiteralNode.new([])
    assert_equal expected_ast, result.ast
    assert_equal [], result.errors
  end

  def test_parse_reject
    result = parse('.12')
    expected_ast = AST::InvalidNode.new(Token.new(Token::DOT))
    assert_equal expected_ast, result.ast
    assert_equal ['unexpected token `.`'], result.errors

    result = parse('1.')
    expected_ast = AST::InvalidNode.new(Token.new(Token::ERROR, 'unexpected EOF'))
    assert_equal expected_ast, result.ast
    assert_equal ['unexpected EOF'], result.errors

    result = parse('012')
    expected_ast = AST::InvalidNode.new(Token.new(Token::ERROR, 'illegal trailing zero in number literal'))
    assert_equal expected_ast, result.ast
    assert_equal ['illegal trailing zero in number literal'], result.errors

    result = parse('- 1')
    expected_ast = AST::InvalidNode.new(Token.new(Token::ERROR, 'unexpected number char: ` `'))
    assert_equal expected_ast, result.ast
    assert_equal ['unexpected number char: ` `'], result.errors

    result = parse('+1')
    expected_ast = AST::InvalidNode.new(Token.new(Token::ERROR, 'unexpected char `+`'))
    assert_equal expected_ast, result.ast
    assert_equal ['unexpected char `+`'], result.errors

    result = parse('[1, 2,]')
    expected_ast = AST::ArrayLiteralNode.new(
      [
        AST::NumberLiteralNode.new('1'),
        AST::NumberLiteralNode.new('2'),
      ],
    )
    assert_equal expected_ast, result.ast
    assert_equal ['illegal trailing comma in array literal'], result.errors

    result = parse('[1, 2')
    expected_ast = AST::ArrayLiteralNode.new(
      [
        AST::NumberLiteralNode.new('1'),
        AST::NumberLiteralNode.new('2'),
      ],
    )
    assert_equal expected_ast, result.ast
    assert_equal ['unexpected `END_OF_FILE`, expected `]`'], result.errors

    result = parse('{ "foo": 1, 2 }')
    expected_ast = AST::ObjectLiteralNode.new(
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
    )
    assert_equal expected_ast, result.ast
    assert_equal ['missing key in object literal for value: `2`'], result.errors

    result = parse('{ "foo": 1, }')
    expected_ast = AST::ObjectLiteralNode.new(
      [
        AST::KeyValuePairNode.new(
          AST::StringLiteralNode.new('foo'),
          AST::NumberLiteralNode.new('1'),
        ),
      ],
    )
    assert_equal expected_ast, result.ast
    assert_equal ['illegal trailing comma in object literal'], result.errors

    result = parse('{ "foo": 1')
    expected_ast = AST::ObjectLiteralNode.new(
      [
        AST::KeyValuePairNode.new(
          AST::StringLiteralNode.new('foo'),
          AST::NumberLiteralNode.new('1'),
        ),
      ],
    )
    assert_equal expected_ast, result.ast
    assert_equal ['unexpected `END_OF_FILE`, expected `}`'], result.errors
  end

  private

  sig { params(source: String).returns(RubyJsonParser::Result) }
  def parse(source)
    RubyJsonParser.parse(source)
  end
end
