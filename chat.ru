require "bundler/setup"
Bundler.setup :redis
require "rack"

$: << File.join(File.dirname(__FILE__), "lib")

require "rubpubsub"
require "#{File.dirname(__FILE__)}/example/chat"

adapter = ENV["REDISTOGO_URL"] || "redis://localhost:6379/"

run Rack::URLMap.new({
  "/rubpubsub"  => RubPubSub.new(:adapter => adapter), 
  "/"           => Chat.new(:rubpubsub => "/rubpubsub")
})
