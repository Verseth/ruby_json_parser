# typed: strong
# frozen_string_literal: true

class RubyJsonParser
  # The result of parsing a JSON string/file
  class Result
    extend T::Sig

    sig { returns(AST::Node) }
    attr_reader :ast

    sig { returns(T::Array[String]) }
    attr_reader :errors

    sig { params(ast: AST::Node, errors: T::Array[String]).void }
    def initialize(ast, errors)
      @ast = ast
      @errors = errors
    end

    sig { returns(T::Boolean) }
    def err?
      @errors.any?
    end

    sig { returns(String) }
    def inspect
      buff = String.new
      buff << "<RubyJsonParser::Result>\n"
      if @errors.any?
        buff << "  !Errors!\n"
        @errors.each do |err|
          buff << "    - #{err}\n"
        end
        buff << "\n"
      end

      buff << "  AST:\n"
      buff << @ast.inspect(2)
    end
  end
end
