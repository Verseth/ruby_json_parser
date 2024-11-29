# typed: true
# frozen_string_literal: true

# rubocop:disable Style/EvalWithLocation

require 'test_helper'

class RubyJsonParser
  class EvaluatorTest < Minitest::Test
    extend T::Sig

    def test_eval
      assert_equal true, eval('true')
      assert_equal false, eval('false')
      assert_nil eval('null')

      assert_equal 42, eval('42')
      assert_equal(-42, eval('-42'))
      assert_equal 0, eval('0')
      assert_equal(-0.1, eval('-0.1'))
      assert_equal 123.346435, eval('123.346435')
      assert_equal 1e+2, eval('1e+2')

      assert_equal 'foo', eval('"foo"')
      assert_equal "l\bo\nl\r", eval('"l\bo\nl\r"')

      assert_equal [], eval('[]')
      assert_equal [true], eval('[true]')
      expected = [1, 2, ['elo', { 'jp2' => 'papież polak', 'kula' => [9.23] }]]
      assert_equal expected, eval('[1, 2, ["elo", { "jp2": "papież polak", "kula": [9.23] }]]')

      assert_equal({}, eval('{}'))
      assert_equal({ 'foo' => 2 }, eval('{ "foo": "bar", "foo": 2 }'))

      assert_raises SyntaxError do
        eval('{ "foo": "bar"')
      end
      assert_raises SyntaxError do
        eval('{ "foo": "bar", }')
      end
    end

    private

    sig { params(source: String).returns(Object) }
    def eval(source)
      Evaluator.eval(source)
    end
  end
end

# rubocop:enable Style/EvalWithLocation
