# typed: strong
# frozen_string_literal: true

module RubyJsonParser
  # Contains the definitions of all AST (Abstract Syntax Tree) nodes.
  # AST is the data structure that is returned by the parser.
  module AST
    # A string that represents a single level of indentation
    # in S-expressions
    INDENT_UNIT = '  '

    # Abstract class representing an AST node.
    class Node
      extend T::Sig
      extend T::Helpers

      abstract!

      # Get the JSON-like representation of the AST
      sig { abstract.returns(String) }
      def to_s; end

      # Inspect the AST in the S-expression format
      sig { abstract.params(indent: Integer).returns(String) }
      def inspect(indent = 0); end
    end

    # Represents an invalid node
    class InvalidNode < Node
      sig { returns(Token) }
      attr_reader :token

      sig { params(token: Token).void }
      def initialize(token)
        @token = token
      end

      sig { params(other: Object).returns(T::Boolean) }
      def ==(other)
        return false unless other.is_a?(InvalidNode)

        token == other.token
      end

      sig { override.returns(String) }
      def to_s
        "<invalid: `#{token}`>"
      end

      sig { override.params(indent: Integer).returns(String) }
      def inspect(indent = 0)
        "#{INDENT_UNIT * indent}(invalid `#{token}`)"
      end
    end

    # Represents a false literal eg. `false`
    class FalseLiteralNode < Node
      sig { params(other: Object).returns(T::Boolean) }
      def ==(other)
        other.is_a?(FalseLiteralNode)
      end

      sig { override.returns(String) }
      def to_s
        'false'
      end

      sig { override.params(indent: Integer).returns(String) }
      def inspect(indent = 0)
        "#{INDENT_UNIT * indent}false"
      end
    end

    # Represents a true literal eg. `true`
    class TrueLiteralNode < Node
      sig { params(other: Object).returns(T::Boolean) }
      def ==(other)
        other.is_a?(TrueLiteralNode)
      end

      sig { override.returns(String) }
      def to_s
        'true'
      end

      sig { override.params(indent: Integer).returns(String) }
      def inspect(indent = 0)
        "#{INDENT_UNIT * indent}true"
      end
    end

    # Represents a true literal eg. `null`
    class NullLiteralNode < Node
      sig { params(other: Object).returns(T::Boolean) }
      def ==(other)
        other.is_a?(NullLiteralNode)
      end

      sig { override.returns(String) }
      def to_s
        'null'
      end

      sig { override.params(indent: Integer).returns(String) }
      def inspect(indent = 0)
        "#{INDENT_UNIT * indent}null"
      end
    end

    # Represents a number literal eg. `123.5`
    class NumberLiteralNode < Node
      sig { returns(String) }
      attr_reader :value

      sig { params(value: String).void }
      def initialize(value)
        @value = value
      end

      sig { params(other: Object).returns(T::Boolean) }
      def ==(other)
        return false unless other.is_a?(NumberLiteralNode)

        value == other.value
      end

      sig { override.returns(String) }
      def to_s
        value
      end

      sig { override.params(indent: Integer).returns(String) }
      def inspect(indent = 0)
        "#{INDENT_UNIT * indent}#{value}"
      end
    end

    # Represents a string literal eg. `"foo"`
    class StringLiteralNode < Node
      sig { returns(String) }
      attr_reader :value

      sig { params(value: String).void }
      def initialize(value)
        @value = value
      end

      sig { params(other: Object).returns(T::Boolean) }
      def ==(other)
        return false unless other.is_a?(StringLiteralNode)

        value == other.value
      end

      sig { override.returns(String) }
      def to_s
        value.inspect
      end

      sig { override.params(indent: Integer).returns(String) }
      def inspect(indent = 0)
        "#{INDENT_UNIT * indent}#{value.inspect}"
      end
    end

    # Represents an object literal eg. `{ "foo": 123 }`
    class ObjectLiteralNode < Node
      sig { returns(T::Array[KeyValuePairNode]) }
      attr_reader :pairs

      sig { params(pairs: T::Array[KeyValuePairNode]).void }
      def initialize(pairs)
        @pairs = pairs
      end

      sig { params(other: Object).returns(T::Boolean) }
      def ==(other)
        return false unless other.is_a?(ObjectLiteralNode)

        pairs == other.pairs
      end

      sig { override.returns(String) }
      def to_s
        buff = String.new
        buff << '{'

        @pairs.each.with_index do |pair, i|
          buff << ', ' if i > 0
          buff << pair.to_s
        end

        buff << '}'
        buff
      end

      sig { override.params(indent: Integer).returns(String) }
      def inspect(indent = 0)
        buff = String.new

        buff << "#{INDENT_UNIT * indent}(object"
        @pairs.each do |pair|
          buff << "\n"
          buff << pair.inspect(indent + 1)
        end
        buff << ')'
        buff
      end
    end

    # Represents a key-value pair eg. `"foo": 123`
    class KeyValuePairNode < Node
      sig { returns(T.nilable(Node)) }
      attr_reader :key

      sig { returns(T.nilable(Node)) }
      attr_reader :value

      sig { params(key: T.nilable(Node), value: T.nilable(Node)).void }
      def initialize(key, value)
        @key = key
        @value = value
      end

      sig { params(other: Object).returns(T::Boolean) }
      def ==(other)
        return false unless other.is_a?(KeyValuePairNode)

        key == other.key && value == other.value
      end

      sig { override.returns(String) }
      def to_s
        return value.to_s unless key

        "#{key}: #{value}"
      end

      sig { override.params(indent: Integer).returns(String) }
      def inspect(indent = 0)
        buff = String.new
        buff << "#{INDENT_UNIT * indent}(pair"

        k = key
        buff << "\n"
        buff <<
          if k
            k.inspect(indent + 1)
          else
            "#{INDENT_UNIT * (indent + 1)}<nil>"
          end

        v = value
        buff << "\n"
        buff <<
          if v
            v.inspect(indent + 1)
          else
            "#{INDENT_UNIT * (indent + 1)}<nil>"
          end

        buff << ')'
        buff
      end
    end

    # Represents an object literal eg. `[1, "foo"]`
    class ArrayLiteralNode < Node
      sig { returns(T::Array[Node]) }
      attr_reader :elements

      sig { params(elements: T::Array[Node]).void }
      def initialize(elements)
        @elements = elements
      end

      sig { params(other: Object).returns(T::Boolean) }
      def ==(other)
        return false unless other.is_a?(ArrayLiteralNode)

        elements == other.elements
      end

      sig { override.returns(String) }
      def to_s
        buff = String.new
        buff << '['

        @elements.each.with_index do |element, i|
          buff << ', ' if i > 0
          buff << element.to_s
        end

        buff << ']'
        buff
      end

      sig { override.params(indent: Integer).returns(String) }
      def inspect(indent = 0)
        buff = String.new

        buff << "#{INDENT_UNIT * indent}(array"
        @elements.each do |element|
          buff << "\n"
          buff << element.inspect(indent + 1)
        end
        buff << ')'
        buff
      end
    end
  end
end
