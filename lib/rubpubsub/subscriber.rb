class RubPubSub::Subscriber < Sinatra::Base
  def initialize(rubpubsub)
    @rubpubsub = rubpubsub
    super
  end
  
  get '/', provides: 'text/event-stream' do
    stream :keep_open do |out|
      timer = EventMachine::PeriodicTimer.new(28) do
        out << "event: keepalive\ndata: \n\n"
      end

      subscription = @rubpubsub.subscribe params[:user], "chat" do |channel, data|
        lines = data.split(/(\r\n|\r|\n)/)
        lines[0] = "channel: #{channel} #{lines[0]}"
        lines = lines.map { |line| "data: #{line}" }
        out << lines.join("\n") << "\n\n"
      end

      out.callback do
        timer.cancel
        @rubpubsub.unsubscribe(subscription)
      end
    end
  end
end
