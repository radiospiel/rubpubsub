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

  # The adapter.
  #
  # The adapter object gets set up during initialization, and adheres 
  # to the RubPubSub::Adapter interface.
  attr_reader :adapter

  extend Forwardable
  delegate [:subscribe, :publish, :unsubscribe] => :adapter
  
  # Build the RubPubSub object.
  #
  # Options:
  # - <tt>:adapter</tt> the URL for the pubsub middleware adapter; see 
  #   RubPubSub::Adapter.create
  def initialize(options = {})
    expect! options => { :adapter => String }

    adapter_url = options[:adapter]

    EM.next_tick do
      @adapter = RubPubSub::Adapter.create(adapter_url)
    end
  end

  def app(mode = :any)
    App.new(self, mode)
  end

  def publisher; app(:publisher); end
  def subscriber; app(:subscriber); end
end

require_relative "rubpubsub/adapter"
require_relative "rubpubsub/app"
