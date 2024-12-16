# RubyJsonParser

This library implements a JSON lexer, parser, evaluator and syntax highlighter in pure Ruby 💎.

It has been built for educational purposes, to serve as a simple example of what makes parsers tick.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add ruby_json_parser

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install ruby_json_parser

## Usage

### Lexer

This library implements a streaming JSON lexer.
You can use it by creating an instance of `RubyJsonParser::Lexer` passing in a string
with JSON source.

You can call the `next` method to receive the next token.
Once the lexing is complete a token of type `:end_of_file` gets returned.

```rb
require 'ruby_json_parser'

lexer = RubyJsonParser::Lexer.new('{ "some": ["json", 2e-29, "text"] }')
lexer.next #=> Token(:lbrace)
lexer.next #=> Token(:string, "some")
lexer.next #=> Token(:colon)
lexer.next #=> Token(:lbracket)
lexer.next #=> Token(:string, "json")
# ...
lexer.next #=> Token(:end_of_file)
```

There is a simplified API that lets you generate an array of all tokens.

```rb
require 'ruby_json_parser'

RubyJsonParser.lex('{ "some": ["json", 2e-29, "text"] }')
#=> [Token(:lbrace), Token(:string, "some"), Token(:colon), Token(:lbracket), Token(:string, "json"), Token(:comma), Token(:number, "2e-29"), Token(:comma), Token(:string, "text"), Token(:rbracket), Token(:rbrace)]
```

### Parser

This library implements a JSON parser.
You can use it by calling `RubyJsonParser.parse` passing in a string
with JSON source.

It returns `RubyJsonParser::Result` which contains the produced AST (Abstract Syntax Tree) and the list of encountered errors.

```rb
require 'ruby_json_parser'

RubyJsonParser.parse('{ "some": ["json", 2e-29, "text"] }')
#=> <RubyJsonParser::Result>
#  AST:
#    (object
#      (pair
#        "some"
#        (array
#          "json"
#          2e-29
#          "text")))

result = RubyJsonParser.parse('[1, 2')
#=> <RubyJsonParser::Result>
#  !Errors!
#    - unexpected `END_OF_FILE`, expected `]`
#
#  AST:
#    (array
#      1
#      2)

result.ast # get the AST
result.err? # check if there are any errors
result.errors # get the list of errors
```

All AST nodes are implemented as classes under the `RubyJsonParser::AST` module.
AST nodes have an `inspect` method that presents their structure in the [S-expression](https://en.wikipedia.org/wiki/S-expression) format.
You can also use `#to_s` to convert them to a JSON-like human readable format.

```rb
result = RubyJsonParser.parse('{"some"   :[   "json",2e-29 ,  "text"  ]}')
ast = result.ast

puts ast.inspect # S-expression format
# (object
#   (pair
#     "some"
#     (array
#       "json"
#       2e-29
#       "text")))

puts ast.to_s # JSON-like format
# {"some": ["json", 2e-29, "text"]}

ast.class #=> RubyJsonParser::AST::ObjectLiteralNode

ast.pairs[0].key #=> RubyJsonParser::AST::StringLiteralNode("some")
ast.pairs[0].value.elements[2] #=> RubyJsonParser::AST::NumberLiteralNode("2e-29")
```

### Evaluator

This library implements a JSON evaluator.
It interprets a JSON source string as builtin Ruby data structures.

You can use it by calling `RubyJsonParser.eval` passing in a string
with JSON source.

It throws `RubyJsonParser::SyntaxError` when the string cannot be parsed.

```rb
RubyJsonParser.eval('{ "some": ["json", 2e-29, "text"] }')
#=> {"some"=>["json", 2.0e-29, "text"]}

RubyJsonParser.eval('{ "some" }')
#! RubyJsonParser::SyntaxError: missing key in object literal for value: `"some"`
```

### Syntax highlighter

This library implements a JSON syntax highlighter based on a lexer.
It tokenizes a JSON source string and returns a new string highlighted with [ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code)

You can use it by calling `RubyJsonParser.highlight` passing in a string
with JSON source.

```rb
RubyJsonParser.highlight('{ "foo": 3, "lol": [5, false, null, dupa] }')
#=> "\e[95m{\e[0m \e[93m\"foo\"\e[0m\e[35m:\e[0m \e[94m3\e[0m\e[35m,\e[0m \e[93m\"lol\"\e[0m\e[35m:\e[0m \e[95m[\e[0m\e[94m5\e[0m\e[35m,\e[0m \e[32m\e[3mfalse\e[0m\e[35m,\e[0m \e[32m\e[3mnull\e[0m\e[35m,\e[0m \e[48;2;153;51;255m\e[9m\e[30mdupa\e[0m\e[95m]\e[0m \e[95m}\e[0m"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Verseth/ruby_json_parser.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
