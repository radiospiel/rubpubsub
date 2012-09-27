#
# Use "rackup" to load the Chat example.

require "json"

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

<pre id='chat'> </pre>

<form>
  <input id='msg' placeholder='type message here...' />
</form>

<pre id='log'> </pre>
<style type="text/css" media="screen">
  #log .error { color: red; }
  #log .info { color: green; }
</style>
<script type="text/javascript" charset="utf-8">
(function(user) {
  var log = {
    info:     function(msg) { log.message(msg, "info"); },
    error:    function(msg) { log.message(msg, "error"); },
    message:  function(msg, klass) {
      $("<div class='" + klass + "'></div>").text(msg).appendTo('#log');
    }
  };

  var url = '/sub?channels=chat,' + user;

  var es = new EventSource(url);
  es.onerror = function(e)   { log.error("EventSource error"); };

    var log_event = function(event) {
      $("<div></div>").text(event.data).appendTo('#chat'); 
    };

    es.addEventListener(user, log_event);
    es.addEventListener('chat', log_event);
  
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

    $.post('/pub', { channels: channels, msg: user + ": " + msg })
      .success(function() { log.info("posted message"); })
      .error(function(e) { log.error("Cannot post message"); });
  }

  // writing
  $("form").live("submit", function(e) {
    publish($('#msg').val());
    
    $('#msg').val(''); $('#msg').focus();
    e.preventDefault();
  });
})(<%= user.to_json %>);
</script>

