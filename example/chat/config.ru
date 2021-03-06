Dir.chdir File.dirname(__FILE__)

require "bundler/setup"
Bundler.setup :redis
require "rack"

$: << File.join(File.dirname(__FILE__), "..", "..", "lib")

require "rubpubsub"
require File.join(File.dirname(__FILE__), "chat.rb")

adapter = ENV["REDISTOGO_URL"] || "redis://localhost:6379/"
rubpubsub = RubPubSub.new(:adapter => adapter)

run Rack::URLMap.new({
  "/pub"  => rubpubsub.publisher,
  "/sub"  => rubpubsub.subscriber,
  "/"     => Chat.new(:rubpubsub => rubpubsub)
})
