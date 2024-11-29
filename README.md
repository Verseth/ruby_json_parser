# RubyJsonParser

This library implements a JSON lexer and parser in pure Ruby 💎.

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
lexer.next #=> Token(:string, "some")
lexer.next #=> Token(:colon)
# ...
lexer.next #=> Token(:end_of_file)
```

There is a simplified API that lets use generate an array of tokens at once.

```rb
require 'ruby_json_parser'

RubyJsonParser::Lexer.lex('{ "some": ["json", 2e-29, "text"] }')
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
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Verseth/ruby_json_parser.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
