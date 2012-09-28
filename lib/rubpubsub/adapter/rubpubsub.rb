require "uri"
require "net/http"

# The Redis adapter for RubPubSub
class RubPubSub::Adapter::RubPubSub
  attr :url
  
  def initialize(url) #:nodoc:
    @url = url
  end

  # subscribe to a channel. Returns a Subscription object.
  def subscribe(channel, &block)
    W "#{url}: connecting"

    url = File.join(@url, channel)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      http.request request do |response|
        message = Struct.new(:data, :id, :event).new
        message.data = []
        flush = lambda do
          unless message.data.empty?
            yield message.event, message.data.join("\n"), message.id
            message.data.clear
          end
          message.event = message.id = nil
        end
        
        response.read_body do |chunk|
          # The String#split limit parameter: 
          #
          # "... If negative, there is no limit to the number of fields
          # returned, <b>and trailing null fields are not suppressed.</b>"
          # (http://www.ruby-doc.org/core-1.9.3/String.html#method-i-split)
          lines = chunk.split("\n", -1)
          
          lines.each do |line|
            key, value = *line.split(/: ?/, 2)
            
            case key
            when nil      then flush.call
            when "id"     then message.id = value
            when "event"  then message.event = value
            when "data"   then message.data << value
            end
          end
        end
      end
    end
  end
  
  # Publish a message to a channel
  def publish(channel, message)
    url = File.join(@url, channel)
    response = Net::HTTP.post_form URI(url), msg: message
    body = response.read_body
    body.split("\n", 2).first
  end
  
  # Unsubscribe a subscription.
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

        message, id = RubPubSub::MessageID.unpack_message_and_id(data)
        subscriptions.each { |subscription| subscription.call(channel, message, id) }
      else
        STDERR.puts "Don't know how to handle #{message.inspect}"
      end
    end
  end
end
