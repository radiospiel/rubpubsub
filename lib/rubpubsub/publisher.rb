class RubPubSub::Publisher < Sinatra::Base
  def initialize(rubpubsub)
    @rubpubsub = rubpubsub
    super
  end
  
  post '/' do
    channel = params[:channel] || "chat"
    @rubpubsub.publish channel, params[:msg]

    204 # response without entity body
  end
end
