# require "bundler/ui"
# require "thor/shell"

module UI
  COLORS = {
    clear:      "\e[0m",  # Embed in a String to clear all previous ANSI sequences.
    bold:       "\e[1m",  # The start of an ANSI bold sequence.
    black:      "\e[30m", # Set the terminal's foreground ANSI color to black.
    red:        "\e[31m", # Set the terminal's foreground ANSI color to red.
    green:      "\e[32m", # Set the terminal's foreground ANSI color to green.
    yellow:     "\e[33m", # Set the terminal's foreground ANSI color to yellow.
    blue:       "\e[34m", # Set the terminal's foreground ANSI color to blue.
    magenta:    "\e[35m", # Set the terminal's foreground ANSI color to magenta.
    cyan:       "\e[36m", # Set the terminal's foreground ANSI color to cyan.
    white:      "\e[37m", # Set the terminal's foreground ANSI color to white.

    on_black:   "\e[40m", # Set the terminal's background ANSI color to black.
    on_red:     "\e[41m", # Set the terminal's background ANSI color to red.
    on_green:   "\e[42m", # Set the terminal's background ANSI color to green.
    on_yellow:  "\e[43m", # Set the terminal's background ANSI color to yellow.
    on_blue:    "\e[44m", # Set the terminal's background ANSI color to blue.
    on_magenta: "\e[45m", # Set the terminal's background ANSI color to magenta.
    on_cyan:    "\e[46m", # Set the terminal's background ANSI color to cyan.
    on_white:   "\e[47m"  # Set the terminal's background ANSI color to white.
  }

  extend self
  
  @@started_at = Time.now
  
  MESSAGE_COLOR = {
    :info     => :cyan,
    :warn     => :yellow,
    :error    => :red,
    :success  => :green,
  }
  def method_missing(sym, msg, *args)
    unless args.empty?
      msg += ": " + args.map(&:inspect).join(", ")
    end

    timestamp = "[%3d msecs]" % (1000 * (Time.now - @@started_at))
    
    if color = COLORS[MESSAGE_COLOR[sym]]
      msg = "#{color}#{timestamp} #{msg}#{COLORS[:clear]}"
    end
    
    STDERR.puts msg
  end
end

def D(*args)
  UI.debug *args
end

def I(*args)
  UI.info *args
end

def W(*args)
  UI.warn *args
end

def E(*args)
  UI.error *args
  exit 1
end

def S(*args)
  UI.success *args
end

def B(msg, *args, &block)
  start = Time.now
  yield.tap do
    msg += ": #{(1000 * (Time.now - start)).to_i} msecs."
    UI.warn msg, *args
  end
end
