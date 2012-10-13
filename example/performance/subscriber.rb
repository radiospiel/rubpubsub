$: << File.join(File.dirname(__FILE__), "..", "..", "lib")
require "rubpubsub/client"

url = ARGV[0] || raise("Missing URL parameter")

client = RubPubSub::Client.new("#{url}/sub")

client.subscribe "test" do |channel, data, id|
  now = Time.now.to_f
  runtime = now - data.to_f
  STDERR.puts "#{id}: #{"%.1f" % (runtime * 1000)} msecs."
end
