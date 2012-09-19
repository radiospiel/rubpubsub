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
class RubPubSub::Subscriber < Sinatra::Base
  def initialize(rubpubsub) #:nodoc:
    @rubpubsub = rubpubsub
    super
  end
  
  helpers do
    def reschedule_keepalive(timer, out)
      if timer
        timer.cancel
      end

      EventMachine::PeriodicTimer.new(28) do 
        # If we would send a real SSE event, it could look like this:
        #
        # out << "event: keepalive\ndata: \n\n"
        #
        # However, according to the spec an empty line should be
        # ignored by the client, and we just need to keep up the 
        # connection, not to transfer any data to the client.
        out << "\n" 
      end
    end
    
    def subscribe(*channels)
      stream :keep_open do |out|
        timer = reschedule_keepalive(timer, out)

        subscription = @rubpubsub.subscribe(*channels) do |channel, data|
          lines = data.split(/(\r\n|\r|\n)/)
          lines[0] = "channel: #{channel} #{lines[0]}"
          lines = lines.map { |line| "data: #{line}" }
          out << lines.join("\n") << "\n\n"

          # We just wrote some output, and therefore can reschedule the 
          # keepalive timer.
          timer = reschedule_keepalive(timer, out)
        end

        out.callback do
          timer.cancel
          @rubpubsub.unsubscribe(subscription)
        end
      end
    end
  end
  
  get '/', provides: 'text/event-stream' do
    channels = params[:channels].split(",")
    subscribe *channels
  end
end
