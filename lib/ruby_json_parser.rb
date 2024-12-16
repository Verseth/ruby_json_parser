# typed: strong
# frozen_string_literal: true

require 'sorbet-runtime'

require_relative 'ruby_json_parser/version'
require_relative 'ruby_json_parser/position'
require_relative 'ruby_json_parser/span'
require_relative 'ruby_json_parser/token'
require_relative 'ruby_json_parser/lexer'
require_relative 'ruby_json_parser/ansi_codes'
require_relative 'ruby_json_parser/highlighter'
require_relative 'ruby_json_parser/ast'
require_relative 'ruby_json_parser/result'
require_relative 'ruby_json_parser/parser'
require_relative 'ruby_json_parser/evaluator'

# Implements a JSON lexer, parser and evaluator in pure Ruby.
# Built for educational purposes.
module RubyJsonParser
  extend T::Sig

  # JSON syntax error
  class SyntaxError < StandardError
    extend T::Sig

    sig { returns(T::Array[String]) }
    attr_reader :errors

    sig { params(errors: T::Array[String]).void }
    def initialize(errors)
      @errors = errors
    end

    sig { returns(String) }
    def message
      @errors.join('; ')
    end
  end

  class << self
    extend T::Sig

    # Tokenize the JSON source string.
    # Carries out lexical analysis and returns
    # an array of tokens (words).
    sig do
      params(
        source: String,
      ).returns(T::Array[Token])
    end
    def lex(source)
      Lexer.lex(source)
    end

    # Parse the JSON source.
    # Returns an AST (Abstract Syntax Tree) and a list of errors.
    sig do
      params(
        source: String,
      ).returns(Result)
    end
    def parse(source)
      Parser.parse(source)
    end

    # Evaluate the JSON source string.
    # Parses the string and interprets it
    # converting the AST into builtin Ruby data structures.
    sig do
      params(
        source: String,
      ).returns(Object)
    end
    def eval(source)
      Evaluator.eval(source)
    end

    # Tokenizes the given source string and creates a new
    # colorized string using ANSI escape codes.
    sig do
      params(
        source: String,
      ).returns(String)
    end
    def highlight(source)
      Highlighter.highlight(source)
    end
  end


end
