# typed: strict
# frozen_string_literal: true

require_relative 'token'

module RubyJsonParser
  # Contains common ANSI escape codes
  module ANSICodes
    RESET = "\e[0m"
    BOLD = "\e[1m"
    FAINT = "\e[2m"
    ITALIC = "\e[3m"
    UNDERLINE = "\e[4m"
    SLOW_BLINK = "\e[5m"
    RAPID_BLINK = "\e[6m"
    STRIKE = "\e[9m"
    ENCIRCLED = "\e[51m"
    FRAMED = "\e[52m"
    OVERLINE = "\e[53m"

    FOREGROUND_BLACK = "\e[30m"
    FOREGROUND_RED = "\e[31m"
    FOREGROUND_GREEN = "\e[32m"
    FOREGROUND_YELLOW = "\e[33m"
    FOREGROUND_BLUE = "\e[34m"
    FOREGROUND_MAGENTA = "\e[35m"
    FOREGROUND_CYAN = "\e[36m"
    FOREGROUND_WHITE = "\e[37m"

    FOREGROUND_BRIGHT_BLACK = "\e[90m"
    FOREGROUND_BRIGHT_RED = "\e[91m"
    FOREGROUND_BRIGHT_GREEN = "\e[92m"
    FOREGROUND_BRIGHT_YELLOW = "\e[93m"
    FOREGROUND_BRIGHT_BLUE = "\e[94m"
    FOREGROUND_BRIGHT_MAGENTA = "\e[95m"
    FOREGROUND_BRIGHT_CYAN = "\e[96m"
    FOREGROUND_BRIGHT_WHITE = "\e[97m"

    BACKGROUND_BLACK = "\e[40m"
    BACKGROUND_RED = "\e[41m"
    BACKGROUND_GREEN = "\e[42m"
    BACKGROUND_YELLOW = "\e[43m"
    BACKGROUND_BLUE = "\e[44m"
    BACKGROUND_MAGENTA = "\e[45m"
    BACKGROUND_CYAN = "\e[46m"
    BACKGROUND_WHITE = "\e[47m"

    BACKGROUND_BRIGHT_BLACK = "\e[100m"
    BACKGROUND_BRIGHT_RED = "\e[101m"
    BACKGROUND_BRIGHT_GREEN = "\e[102m"
    BACKGROUND_BRIGHT_YELLOW = "\e[103m"
    BACKGROUND_BRIGHT_BLUE = "\e[104m"
    BACKGROUND_BRIGHT_MAGENTA = "\e[105m"
    BACKGROUND_BRIGHT_CYAN = "\e[106m"
    BACKGROUND_BRIGHT_WHITE = "\e[107m"

    class << self
      extend T::Sig

      sig { params(r: Integer, g: Integer, b: Integer).returns(String) }
      def rgb_foreground(r, g, b)
        "\e[38;2;#{r};#{g};#{b}m"
      end

      sig { params(r: Integer, g: Integer, b: Integer).returns(String) }
      def rgb_background(r, g, b)
        "\e[48;2;#{r};#{g};#{b}m"
      end

      # Creates a new string prepended with the given ANSI escape codes.
      # Styles are reset at the end of the string.
      sig { params(str: String, codes: T::Array[String]).returns(String) }
      def style(str, codes)
        return str if codes.length == 0

        buff = String.new
        codes.each do |code|
          buff << code
        end
        buff << str << RESET
      end

      # Creates a new string prepended with the given ANSI escape codes.
      # Styles are reset at the end of the string.
      sig { params(str: String, codes: String).returns(String) }
      def style!(str, *codes)
        return str if codes.length == 0

        buff = String.new
        codes.each do |code|
          buff << code
        end
        buff << str << RESET
      end
    end
  end
end
