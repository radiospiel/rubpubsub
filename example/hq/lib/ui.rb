# require "bundler/ui"
# require "thor/shell"

module UI
  extend self
  
  @@started_at = Time.now
  
  def method_missing(sym, msg, *args)
    unless args.empty?
      msg += ": " + args.map(&:inspect).join(", ")
    end

    timestamp = "[%3d msecs]" % (1000 * (Time.now - @@started_at))
    STDERR.puts "#{timestamp} #{msg}"
  end
end

#UI = {} #Bundler::UI::Shell.new(Thor::Shell::Color.new)

def D(*args)
  UI.info *args
end

def W(*args)
  UI.warn *args
end

def E(*args)
  UI.error *args
  exit 1
end

def B(msg, *args, &block)
  UI.warn msg, *args

  start = Time.now
  yield.tap do
    msg += ": #{(1000 * (Time.now - start)).to_i} msecs."
    UI.warn msg, *args
  end
end

# # Success!
# def S(*args)
#   UI.confirm UI.format_log_message(*args)
# end
