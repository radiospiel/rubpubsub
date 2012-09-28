# The publisher part of the RubPubSub::App
require 'digest/sha1'

class RubPubSub::App
  @@counter = 0
  
  post '/:channel?' do
    raise Sinatra::NotFound unless publisher?

    message_ids = channels.map do |channel|
      @rubpubsub.publish channel, params[:msg]
    end

    # 204 # response without entity body
    content_type 'text/plain', :charset => 'utf-8'
    message_ids.join("\n") + "\n"
  end
end
