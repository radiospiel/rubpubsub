$: << File.join(File.dirname(__FILE__), "..", "..", "lib")
require "rubpubsub/client"
require "eventmachine"

FREQUENCY = 50 # events per second

url = ARGV[0] || raise("Missing URL parameter")
client = RubPubSub::Client.new("#{url}/pub")

EM.run do
  EventMachine::PeriodicTimer.new(1.0 / FREQUENCY) do 
    id = client.publish "test", Time.now.to_f
    STDERR.puts "#{id}: sent" 
  end
end
