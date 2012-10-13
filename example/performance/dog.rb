time = STDIN.read.to_f
runtime = Time.now.to_f - time
channel, id = ARGV
STDERR.puts "#{id}: #{"%.1f" % (runtime * 1000)} msecs."
