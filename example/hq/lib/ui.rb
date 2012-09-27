require "bundler/ui"
require "thor/shell"

UI = Bundler::UI::Shell.new(Thor::Shell::Color.new)

def UI.format_log_message(msg, *args)
  return msg if args.empty?
  "#{msg}: " + args.map(&:inspect).join(", ")
end

def D(*args)
  UI.info UI.format_log_message(*args)
end

def W(*args)
  UI.warn UI.format_log_message(*args)
end

def E(*args)
  UI.error UI.format_log_message(*args)
  exit 1
end

def B(*args, &block)
  msg = UI.format_log_message(*args)
  W msg

  start = Time.now
  yield.tap do
    W "#{msg}: #{(1000 * (Time.now - start)).to_i} msecs."
  end
end

# Success!
def S(*args)
  UI.confirm UI.format_log_message(*args)
end
