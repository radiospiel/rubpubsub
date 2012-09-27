#
# The RubPubSub subscriber rack app.
#
# This rack app is intended to be mounted via Rack::URLMap, a la
# 
#     rubpubsub = RubPubSub.new(:adapter => adapter)
#     
#     run Rack::URLMap.new({
#       "/pub"  => rubpubsub.publisher,
#       "/sub"  => rubpubsub.subscriber,
#       ...
#     })
#
class RubPubSub::App < Sinatra::Base
  attr :rubpubsub
  
  def initialize(rubpubsub, mode = :any) #:nodoc:
    expect! rubpubsub => RubPubSub, mode => [:any, :publisher, :subscriber]

    @rubpubsub = rubpubsub
    
    @publisher = [:any, :publisher].include? mode
    @subscriber = [:any, :subscriber].include? mode

    super()
  end
  
  def publisher?; @publisher; end
  def subscriber?; @subscriber; end

  helpers do
    def channels
      case channels = params[:channels]
      when Array  then :nop
      when String then channels = channels.split(",")
      else        channels = []
      end
      
      if (channel = params[:channel]) && channel != ""
        channels << channel
      end
      
      channels
    end
  end
end

require_relative "publisher"
require_relative "subscriber"
