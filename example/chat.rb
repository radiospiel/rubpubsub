#
# Use chat.ru to load the Chat example.

class Chat < Sinatra::Base
  enable :inline_templates
  
  def initialize(options = {})
    expect! options => { 
      :rubpubsub => [RubPubSub, nil]
    }

    @rubpubsub = options[:rubpubsub]
    super
  end

  get '/' do
    halt erb(:login) unless params[:user]
    
    @rubpubsub.publish "chat", "Welcome #{params[:user]}"
    erb :chat, locals: { user: params[:user].gsub(/\W/, '') }
  end
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
  <input name='user' value='' id='user'/>
  <input type='submit' value="GO!" />
</form>

@@ chat
<h1>This is a chat</h1>
<pre id='chat'></pre>

<script type="text/javascript" charset="utf-8">
  var user = '<%= user %>';
  var url = '/sub?channels=chat,' + user;
  var es = new EventSource(url);
  es.onmessage = function(e) { $('#chat').append(e.data + "\n"); };

  function publish(msg) {
    // Find channels from the message. A message that mentions 
    // other users via "@" gets sent only to those.
    var channels = [];
    var handles = msg.match(/@([a-z]+)/g);
    if(handles) {
      for(var i=0; i < handles.length; ++i)
        channels.push(handles[i].substr(1));
    }
    if(channels.length == 0) 
      channels.push("chat");

    $.post('/pub', {channels: channels, msg: user + ": " + msg});
  }

  // writing
  $("form").live("submit", function(e) {
    publish($('#msg').val());
    
    $('#msg').val(''); $('#msg').focus();
    e.preventDefault();
  });
</script>

<form>
  <input id='msg' placeholder='type message here...' />
</form>
