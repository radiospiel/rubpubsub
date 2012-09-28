require "uri"
require "net/http"

# The Redis adapter for RubPubSub
class RubPubSub::Adapter::RubPubSub
  attr :url
  
  def initialize(url) #:nodoc:
    @url = url
  end

  def blocking_subscribe(channel, options = {}, &block)
    retrying do
      do_subscribe channel, options, &block
    end
  end
  
  def publish(channel, message)
    retrying do
      do_publish channel, message
    end
  end
  
  private
  
  # subscribe to a channel. Returns a Subscription object.
  def do_subscribe(channel, options = {}, &block)
    W "#{url}: connecting"
    said_hello = true
    if options[:hello]
      said_hello = false
    end
    
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
          unless said_hello
            yield :subscribed, nil, nil
            said_hello = true
          end
          
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
  def do_publish(channel, message)
    url = File.join(@url, channel)
    response = Net::HTTP.post_form URI(url), msg: message
    body = response.read_body
    body.split("\n", 2).first
  end
  
  # retry the block on connection errors.
  def retrying(options = {}, &block)
    sleep = options[:sleep] || 0.1
    repeat = options[:repeat] || 8

    while true do
      begin
        return yield
      rescue Errno::ECONNREFUSED
        if repeat == 0
          E "[#{CommandLine.url}] Cannot connect, giving up."
        end

        repeat -= 1
        sleep *= 1.5

        Thread.send :sleep, sleep
      end
    end
  end
end
