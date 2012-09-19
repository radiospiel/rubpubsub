#
# The RubPubSub publisher rack app.
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

class RubPubSub::Publisher < Sinatra::Base
  def initialize(rubpubsub) #:nodoc:
    @rubpubsub = rubpubsub
    super
  end
  
  post '/' do
    channel = params[:channel] || "chat"
    @rubpubsub.publish channel, params[:msg]

    204 # response without entity body
  end
end
