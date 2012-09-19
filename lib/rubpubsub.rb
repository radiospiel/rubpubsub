require 'sinatra/base'
require 'expectation'
require 'eventmachine'
require "uri"

# The RubPubSub class implements a ServerSideEvents-based pubsub
# rack application. Mount it at a given mount point a la: 
# 
#   run Rack::URLMap.new({
#     "/rubpubsub"  => RubPubSub.new(:adapter => "redis://localhost:6379/"), 
#     "/"           => Chat.new
#   })
class RubPubSub
  attr :adapter

  extend Forwardable
  delegate [:subscribe, :publish, :unsubscribe] => :adapter
  
  # Build the RubPubSub object.
  #
  # Options:
  # - <b>:adapter</b> the URL for the pubsub middleware adapter; see 
  #   RubPubSub::Adapter.create
  def initialize(options = {})
    expect! options => { :adapter => String }

    adapter_url = options[:adapter]

    EM.next_tick do
      @adapter = RubPubSub::Adapter.create(adapter_url)
    end
  end
  
  # returns the publisher rack app
  def publisher
    @publisher ||= Publisher.new(self)
  end

  # returns the subscriber rack app
  def subscriber
    @subscriber ||= Subscriber.new(self)
  end
end

require_relative "rubpubsub/adapter"
require_relative "rubpubsub/publisher"
require_relative "rubpubsub/subscriber"
