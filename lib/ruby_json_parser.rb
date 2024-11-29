# typed: strong
# frozen_string_literal: true

require 'sorbet-runtime'

require_relative 'ruby_json_parser/version'
require_relative 'ruby_json_parser/token'
require_relative 'ruby_json_parser/lexer'
require_relative 'ruby_json_parser/ast'
require_relative 'ruby_json_parser/result'

# Implements a JSON parser in pure Ruby.
# Built for educational purposes.
class RubyJsonParser
  extend T::Sig

  class << self
    extend T::Sig

    sig do
      params(
        source: String,
      ).returns(Result)
    end
    def parse(source)
      new(source).parse
    end
  end

  sig { params(source: String).void }
  def initialize(source)
    # Lexer/Tokenizer that produces tokens
    @lexer = T.let(Lexer.new(source), Lexer)
    # Next token used for predicting productions
    @lookahead = T.let(Token.new(Token::NONE), Token)
    @errors = T.let([], T::Array[String])
  end

  sig { returns(Result) }
  def parse
    advance # populate @lookahead
    ast = parse_value
    Result.new(ast, @errors)
  end

  private

  sig { returns(AST::Node) }
  def parse_value
    case @lookahead.type
    when Token::FALSE
      advance
      AST::FalseLiteralNode.new
    when Token::TRUE
      advance
      AST::TrueLiteralNode.new
    when Token::NULL
      advance
      AST::NullLiteralNode.new
    when Token::NUMBER
      tok = advance
      AST::NumberLiteralNode.new(T.must(tok.value))
    when Token::STRING
      tok = advance
      AST::StringLiteralNode.new(T.must(tok.value))
    when Token::LBRACKET
      parse_array
    when Token::LBRACE
      parse_object
    else
      tok = advance
      add_error("unexpected token `#{tok}`") if tok.type != Token::ERROR
      AST::InvalidNode.new(tok)
    end
  end

  sig { returns(AST::Node) }
  def parse_object
    advance # swallow `{`
    return AST::ObjectLiteralNode.new([]) if match(Token::RBRACE)

    pairs = parse_key_value_pairs
    consume(Token::RBRACE)
    AST::ObjectLiteralNode.new(pairs)
  end

  sig { returns(T::Array[AST::KeyValuePairNode]) }
  def parse_key_value_pairs
    elements = [parse_key_value_pair]

    loop do
      break if accept(Token::END_OF_FILE, Token::RBRACE)
      break unless match(Token::COMMA)

      if accept(Token::RBRACE)
        add_error('illegal trailing comma in object literal')
        break
      end

      elements << parse_key_value_pair
    end

    elements
  end

  sig { returns(AST::KeyValuePairNode) }
  def parse_key_value_pair
    key = parse_value
    if accept(Token::COMMA, Token::RBRACE, Token::END_OF_FILE)
      add_error("missing key in object literal for value: `#{key}`")
      return AST::KeyValuePairNode.new(nil, key)
    end

    add_error("non-string key in object literal: `#{key}`") unless key.is_a?(AST::StringLiteralNode)
    consume(Token::COLON)
    value = parse_value

    AST::KeyValuePairNode.new(key, value)
  end

  sig { returns(AST::Node) }
  def parse_array
    advance # swallow `[`
    return AST::ArrayLiteralNode.new([]) if match(Token::RBRACKET)

    elements = parse_array_elements
    consume(Token::RBRACKET)
    AST::ArrayLiteralNode.new(elements)
  end

  sig { returns(T::Array[AST::Node]) }
  def parse_array_elements
    elements = [parse_value]

    loop do
      break if accept(Token::END_OF_FILE, Token::RBRACKET)
      break unless match(Token::COMMA)

      if accept(Token::RBRACKET)
        add_error('illegal trailing comma in array literal')
        break
      end

      elements << parse_value
    end

    elements
  end

  # Move over to the next token.
  sig { returns(Token) }
  def advance
    previous = @lookahead
    @lookahead = @lexer.next
    handle_error_token(@lookahead) if @lookahead.type == Token::ERROR

    previous
  end

  # Add the content of an error token to the syntax error list.
  sig { params(err: Token).void }
  def handle_error_token(err)
    msg = err.value
    return unless msg

    add_error(msg)
  end

  # Register a syntax error
  sig { params(err: String).void }
  def add_error(err)
    @errors << err
  end

  # Checks if the next token matches any of the given types,
  # if so it gets consumed.
  sig { params(token_types: Symbol).returns(T.nilable(Token)) }
  def match(*token_types)
    token_types.each do |type|
      return advance if accept(type)
    end

    nil
  end

  # Checks whether the next token matches any the specified types.
  sig { params(token_types: Symbol).returns(T::Boolean) }
  def accept(*token_types)
    token_types.each do |type|
      return true if @lookahead.type == type
    end

    false
  end

  sig { params(token_type: Symbol).returns([Token, T::Boolean]) }
  def consume(token_type)
    return advance, false if @lookahead.type == Token::ERROR

    if @lookahead.type != token_type
      error_expected(Token.type_to_string(token_type))
      return advance, false
    end

    [advance, true]
  end

  # Adds an error which tells the user that another type of token
  # was expected.
  sig { params(expected: String).void }
  def error_expected(expected)
    add_error("unexpected `#{@lookahead}`, expected `#{expected}`")
  end
end
