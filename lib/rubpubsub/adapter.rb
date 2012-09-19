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
  # to unsubscribe these subscription. This message must not block.
  def subscribe(*channels, &block)
  end

  #
  # Unsubscribe a subscription. The subscription must be an object 
  # returned from subscribe. This message may block.
  def unsubscribe(subscription)
  end
  
  #
  # Publish a message in a channel. This message may block.
  def publish(channel, message)
  end
end

class RubPubSub::Adapter
  def self.redis(url) #:nodoc:
    require_relative "adapter/redis"

    RubPubSub::Adapter::Redis.new(url)
  end

  # Create a RubPubSub::Adapter.
  #
  # Currently the only supported URL schema is 
  #
  #   redis://[user:password@]host:port/
  #
  def self.create(url)
    expect! URI.parse(url).scheme => "redis"
    
    self.redis(url)
  end
end
