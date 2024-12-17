# typed: true
# frozen_string_literal: true

require 'test_helper'

module RubyJsonParser
  class HighlighterTest < TestCase
    def test_highlight
      result = Highlighter.highlight('   { "foo": 3, "lol": [5, false, null, dupa] }   ')
      expected = "   \e[95m{\e[0m \e[93m\"foo\"\e[0m\e[35m:\e[0m \e[94m3\e[0m\e[35m,\e[0m " \
                 "\e[93m\"lol\"\e[0m\e[35m:\e[0m \e[95m[\e[0m\e[94m5\e[0m\e[35m,\e[0m " \
                 "\e[32m\e[3mfalse\e[0m\e[35m,\e[0m \e[32m\e[3mnull\e[0m\e[35m,\e[0m " \
                 "\e[41m\e[9m\e[30mdupa\e[0m\e[95m]\e[0m \e[95m}\e[0m   "
      assert_equal expected, result
    end

  end
end
