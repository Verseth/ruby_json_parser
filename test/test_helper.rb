# typed: true
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'ruby_json_parser'

require 'minitest/autorun'

class TestCase < Minitest::Test
  extend T::Sig

  sig { params(index: Integer).returns(RubyJsonParser::Position) }
  def P(index) # rubocop:disable Naming/MethodName
    RubyJsonParser::Position.new(index)
  end

  sig { params(start: RubyJsonParser::Position, end_pos: RubyJsonParser::Position).returns(RubyJsonParser::Span) }
  def S(start, end_pos) # rubocop:disable Naming/MethodName
    RubyJsonParser::Span.new(start, end_pos)
  end
end
