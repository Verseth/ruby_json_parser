# typed: strict
# frozen_string_literal: true

require_relative 'token'

class RubyJsonParser
  # An evaluator for JSON.
  # Creates Ruby structures based on an JSON AST.
  module Evaluator
    # Eval error
    class Error < StandardError; end

    class << self
      extend T::Sig

      sig { params(source: String).returns(Object) }
      def eval(source)
        result = RubyJsonParser.parse(source)
        raise SyntaxError.new(result.errors) if result.err?

        eval_node(result.ast)
      end

      sig { params(node: AST::Node).returns(Object) }
      def eval_node(node)
        case node
        when AST::NullLiteralNode
          nil
        when AST::FalseLiteralNode
          false
        when AST::TrueLiteralNode
          true
        when AST::StringLiteralNode
          eval_string(node)
        when AST::NumberLiteralNode
          eval_number(node)
        when AST::ArrayLiteralNode
          eval_array(node)
        when AST::ObjectLiteralNode
          eval_object(node)
        else
          raise Error, "invalid AST node: #{node.class}"
        end
      end

      private

      sig { params(node: AST::StringLiteralNode).returns(String) }
      def eval_string(node)
        node.value
      end

      sig { params(node: AST::NumberLiteralNode).returns(T.any(Integer, Float)) }
      def eval_number(node)
        Integer(node.value)
      rescue ArgumentError
        node.value.to_f
      end

      sig { params(node: AST::ArrayLiteralNode).returns(T::Array[Object]) }
      def eval_array(node)
        node.elements.map do |element|
          eval_node(element)
        end
      end

      sig { params(node: AST::ObjectLiteralNode).returns(T::Hash[String, Object]) }
      def eval_object(node)
        result = {}
        node.pairs.each do |pair|
          key = T.cast(pair.key, AST::StringLiteralNode)
          val = T.must pair.value
          result[eval_string(key)] = eval_node(val)
        end

        result
      end
    end

  end
end
