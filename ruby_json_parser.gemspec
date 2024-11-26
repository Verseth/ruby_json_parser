# frozen_string_literal: true

require_relative "lib/ruby_json_parser/version"

Gem::Specification.new do |spec|
  spec.name = "ruby_json_parser"
  spec.version = RubyJsonParser::VERSION
  spec.authors = ["Mateusz Drewniak"]
  spec.email = ["matmg24@gmail.com"]

  spec.summary = "A JSON parser written in pure Ruby. Built for educational purposes."
  spec.description = spec.summary
  spec.homepage = "https://github.com/Verseth/ruby_json_parser"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .gitlab-ci.yml appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "sorbet-runtime"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
