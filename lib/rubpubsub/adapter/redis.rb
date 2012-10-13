require "uri"
require "redis"
require "uuid"
require_relative "evented_redis"

# The Redis adapter for RubPubSub. 
#
# This adapter DOES NOT map incoming subcriptions onto individual redis 
# channels. Why?
#
# Would we use one redis channel per RubPubSub channel, then each incoming
# RubPubSub connection required not only the connection to the SSE client,
# but an additional connection to the Redis server to. As file handles 
# and sockets are limited resources this would quickly exhaust the available 
# resources.
#
# Instead we use ONE redis channel for all rubpubsub connections; this
# code is simpler than the second case and the high usage scenario of 
# that case anyways.
#
# The channel name is read from the URL in the constructor. If there is none,
# then we'll set a default name.
class RubPubSub::Adapter::Redis

  # The default redis channel for the RubPubSub adapter.
  DEFAULT_CHANNEL = "RubPubSub"

  def initialize(url) #:nodoc:
    @subscriptions_by_channel = Hash.new { |hash, key| hash[key] = Set.new }

    uri = URI.parse(url)

    @redis_channel = uri.path.gsub(/^\//, "")
    if @redis_channel.empty?
      @redis_channel = DEFAULT_CHANNEL
    end

    @subscriber = ::EventedRedis.connect(host: uri.host, port: uri.port, password: uri.password)
    @publisher = ::Redis.new(host: uri.host, port: uri.port, password: uri.password)
  
    redis_subscribe
  end

  # The Subscription object.
  class Subscription #:nodoc:
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
      channels.each do |channel|
        @subscriptions_by_channel[channel] << subscription
      end
    end
  end

  @@uuid ||= UUID.new
  
  # Publish a message to a channel
  #
  # Parameters:
  # - +channel+: the name of the channel
  # - +message+: the message to send
  # - +options+: an options hash, with these potential keys:
  #   - +id+: the id of the message.
  def publish(channel, message, options = {})
    id = options[:id] || @@uuid.generate
    @publisher.publish @redis_channel, pack_message(message, :id => id, :channel => channel)
    id
  end
  
  # Unsubscribe a subscription.
  def unsubscribe(subscription)
    # expect! subscription => Subscription
    
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
  end

  private
  
  # returns an array of names of subscribed channels.
  def subscribed_channels
    @subscriptions_by_channel.keys
  end
  
  # subscribe to the rubpubsub channel
  def redis_subscribe
    @subscriber.subscribe(@redis_channel) do |message, _, data|
      case message
      when "subscribe"
        # nop
      when "unsubscribe"
        # nop
      when "message"
        body, headers = unpack_message(data)
        channel, id = headers.values_at(:channel, :id)

        @subscriptions_by_channel[channel].each do |subscription| 
          subscription.call(channel, body, id) 
        end
      else
        STDERR.puts "Don't know how to handle #{message.inspect}"
      end
    end
  end
  
  def pack_message(body, headers)
    header = headers.map { |k,v| "#{k}: #{v}\n" }.join
    "#{header}\n#{body}"
  end

  def unpack_message(msg)
    header, body = msg.split("\n\n")
    
    headers = header.split("\n").inject({}) do |hash, line|
      key, value = line.split(": ", 2)
      hash.update key.to_sym => value
    end

    [ body, headers ]
  end
end
