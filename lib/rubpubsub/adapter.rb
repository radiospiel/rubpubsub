require "uri"

# The RubPubSub::Adapter class is here mainly for documentation purposes.
class RubPubSub::Adapter
  #
  # Subscribe to one or more channels. Whenever a message is
  # published in one of the channels the block is called with
  # the channel name and the message.
  #
  #   adapter.subscribe "channel1", "channel2" do |channel, message|
  #     ..
  #   end
  #
  # The subscribe method returns an identifier which is later used
  # to unsubscribe these subscription. <b>This method must not block.</b>
  def subscribe(*channels, &block)
  end

  #
  # Unsubscribe a subscription. The subscription must be an object 
  # returned from subscribe. <b>This method may block.</b>
  def unsubscribe(subscription)
  end
  
  #
  # Publish a message in a channel. Returns a message id.
  # <b>This method may block.</b>
  def publish(channel, message)
  end
end

class RubPubSub::Adapter
  SUPPORTED_SCHEMES = %w(redis)
  
  # Create a RubPubSub::Adapter.
  #
  # Currently the only supported URL schema is 
  #
  # <tt>redis://[user:password@]host:port/</tt>
  #
  # There is no support yet to choose a redis database or a namespace.
  def self.create(url)
    expect! URI.parse(url).scheme => SUPPORTED_SCHEMES
    
    send URI.parse(url).scheme, url
  end
  
  def self.redis(url) #:nodoc:
    require_relative "adapter/redis"
    RubPubSub::Adapter::Redis.new(url)
  end
end
