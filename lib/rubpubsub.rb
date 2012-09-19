require 'sinatra/base'
require 'expectation'
require 'eventmachine'
require "uri"

class RubPubSub < Sinatra::Base
  attr :adapter
  
  def initialize(options = {})
    expect! options => { :adapter => String }

    EM.next_tick do
      @adapter = RubPubSub::Adapter.load(options[:adapter])
    end
    
    super
  end
  
  get '/subscribe', provides: 'text/event-stream' do
    stream :keep_open do |out|
      timer = EventMachine::PeriodicTimer.new(28) do
        out << "event: keepalive\ndata: \n\n"
      end

      subscription = adapter.subscribe params[:user], "chat" do |channel, data|
        lines = data.split(/(\r\n|\r|\n)/)
        lines[0] = "channel: #{channel} #{lines[0]}"
        lines = lines.map { |line| "data: #{line}" }
        out << lines.join("\n") << "\n\n"
      end

      out.callback do
        timer.cancel
        adapter.unsubscribe(subscription)
      end
    end
  end

  post '/publish' do
    channel = params[:channel] || "chat"
    adapter.publish channel, msg

    204 # response without entity body
  end
end

require_relative "rubpubsub/adapter"
