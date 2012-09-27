# The publisher part of the RubPubSub::App

class RubPubSub::App
  post '/' do
    raise Sinatra::NotFound unless publisher?
    
    channels = params[:channels] || []
    channels.each do |channel|
      @rubpubsub.publish channel, params[:msg]
    end

    204 # response without entity body
  end
end
