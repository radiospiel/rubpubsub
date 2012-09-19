require "uri"
require "redis"
require_relative "evented_redis"

class RubPubSub::Adapter::Redis
  def initialize(url)
    @subscriptions_by_channel = Hash.new { |hash, key| hash[key] = [] }

    uri = URI.parse(url)

    @subscriber = ::EventedRedis.connect(host: uri.host, port: uri.port, password: uri.password)
    @publisher = ::Redis.new(host: uri.host, port: uri.port, password: uri.password)
  end

  # The Subscription object.
  class Subscription
    extend Forwardable
    delegate :call => :"@block"
    
    attr_reader :channels
    
    def initialize(channels, &block) #:nodoc:
      @channels = channels.dup
      @block = block
    end
  end

  # subscribe to a channel. Returns a Subscription object.
  def subscribe(*channels, &block)
    raise ArgumentError if channels.empty?
    
    Subscription.new(channels, &block).tap do |subscription|
      resubscribe_if_needed do
        channels.each do |channel|
          @subscriptions_by_channel[channel] << subscription
        end
      end
    end
  end

  def publish(channel, message)
    @publisher.publish channel, message
  end
  
  def unsubscribe(subscription)
    #
    # Remove subscription from all stored subscriptions.
    subscription.channels.each do |channel|
      @subscriptions_by_channel[channel].reject! do |stored_subscription|
        stored_subscription.object_id == subscription.object_id
      end
    end

    #
    # Remove empty channels from subscriptions_by_channel. This is
    # important as this removes the Subscription objects from memory
    # which gives the VM a chance to clean up the stored blocks
    # and their bindings.
    #
    empty_channels = @subscriptions_by_channel.
      select { |channel, subscriptions| subscriptions.empty? }.
      map(&:first)
    
    empty_channels.
      each { |channel| @subscriptions_by_channel.delete channel }

    #
    # Note that we do not resubscribe, even if there are have less channels
    # than before. Instead wait for the next subscription to resubscribe.
  end

  private
  
  # returns an array of names of subscribed channels.
  def subscribed_channels
    @subscriptions_by_channel.keys
  end
  
  # yield to the block, and resubscribe, if there are any new
  # subscribed channels
  def resubscribe_if_needed(&block)
    initially_subscribed_channels = subscribed_channels.dup

    yield
  ensure
    return if (subscribed_channels - initially_subscribed_channels).empty?
    resubscribe
  end

  # re-subscribe @subscriber
  def resubscribe
    @subscriber.unsubscribe
    
    @subscriber.subscribe(*subscribed_channels) do |message, channel, data|
      case message
      when "subscribe"
        # nop
      when "unsubscribe"
        # nop
      when "message"
        subscriptions = @subscriptions_by_channel[channel]
        subscriptions.each { |subscription| subscription.call(channel, data) }
      else
        STDERR.puts "Don't know how to handle #{message.inspect}"
      end
    end
  end
end
