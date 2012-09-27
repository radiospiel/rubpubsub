# The subscriber part of the RubPubSub::App

class RubPubSub::App
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

        subscription = rubpubsub.subscribe(*channels) do |channel, data|
          lines = data.split(/(\r\n|\r|\n)/)
          lines = lines.map { |line| "data: #{line}" }
          lines.unshift "event: #{channel}"
          out << lines.join("\n") << "\n\n"

          # We just wrote some output, and therefore can reschedule the 
          # keepalive timer.
          timer = reschedule_keepalive(timer, out)
        end

        out.callback do
          timer.cancel
          rubpubsub.unsubscribe(subscription)
        end
      end
    end
  end
  
  get '/:channel?', provides: 'text/event-stream' do
    raise Sinatra::NotFound unless subscriber?
    subscribe *channels
  end
end
