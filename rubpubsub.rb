require 'sinatra'

set server: 'thin', connections: []
set port: ENV["PORT"] || 4567

require_relative "lib/pub_sub_adapter"

require 'eventmachine'
EM.next_tick do
  url = ENV["REDISTOGO_URL"] || "redis://localhost:6379/"
  $pubsub = PubSubAdapter.redis(url)
end

get '/' do
  halt erb(:login) unless params[:user]
  erb :chat, locals: { user: params[:user].gsub(/\W/, '') }
end

get '/subscribe', provides: 'text/event-stream' do
  stream :keep_open do |out|
    timer = EventMachine::PeriodicTimer.new(28) do
      out << "event: keepalive\ndata: \n\n"
    end

    subscription = $pubsub.subscribe params[:user], "chat" do |channel, data|
      out << "data: channel: #{channel} #{data}\n\n"
    end
    
    out.callback do
      timer.cancel
      $pubsub.unsubscribe(subscription)
    end
  end
end

post '/publish' do
  msg = params[:msg].to_s
  # A message is <author>: [@<receiver> ]message, for example:
  #   "other: @other what do you mean?"
  #
  # If there is a receiver the message will be posted only to the receiver's channel.
  # Otherwise it will be posted to the "chat" channel.
  if msg =~ /^(\S+): @(\S+)(.*)/
    channel = $2
  else
    channel = "chat"
  end
  $pubsub.publish channel, "#{msg}\n"

  204 # response without entity body
end

__END__

@@ layout
<html>
  <head> 
    <title>Super Simple Chat with Sinatra</title> 
    <meta charset="utf-8" />
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"></script> 
  </head> 
  <body><%= yield %></body>
</html>

@@ login
<form action='/'>
  <label for='user'>User Name:</label>
  <input name='user' value='' />
  <input type='submit' value="GO!" />
</form>

@@ chat
<pre id='chat'></pre>

<script>
  // reading
  var es = new EventSource('/subscribe?user=<%= user %>');
  es.onmessage = function(e) { $('#chat').append(e.data + "\n"); };
  es.addEventListener('keepalive', function(e) {
    $('#chat').append("."); 
  }, false);

  // writing
  $("form").live("submit", function(e) {
    $.post('/publish', {msg: "<%= user %>: " + $('#msg').val()});
    $('#msg').val(''); $('#msg').focus();
    e.preventDefault();
  });
</script>

<form>
  <input id='msg' placeholder='type message here...' />
</form>
