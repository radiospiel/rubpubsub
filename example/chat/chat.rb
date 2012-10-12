# This file is part of the rubpubsub ruby gem.
#
# Copyright (c) 2011, 2012, Enrico Thierbach,
# Distributed under the terms of the modified BSD license, see LICENSE.BSD

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
    <script src="/js/jquery.min.js"></script> 
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
<style type="text/css">

body {
  background-color: black;
  margin: 0;
  padding: 4px; 
}

#page {
  width: 100%;
  height: 100%;
  overflow: hidden;
  position: relative;
}
#page .left {
  width: 85%;
  height: 100%;
  top: 0;
  left: 0;
  position: absolute;
}
#page .right {
  width: 15%;
  height: 100%;
  top: 0;
  right: 0;
  position: absolute;
  background-color: #222;
}

#chat {
  background: black;
  color: white;  
  overflow: auto;
  font-family: monospace;
  width: 100%;
  height: 90%;
}

#msg { 
  width: 100%; 
  position: absolute;
  bottom: 2em;
}

#log {
}

#log .error { color: red; }
#log .info { color: lightgreen; }


</style>

<div id="page">
  <div class="left">
    <div id='chat'> 
      <div>
        <p>
        Hi. I am a HTTP-friendly chat application.
        </p>
        <p>
        I read server sent events to show you what is going on, I send
        notifications via HTTP POST.
      </p>
      <p>
        I am built using the rubpubsub gem. In fact, I am one of the example applications therre.
        Find my source code here: <a href="http://github.com/radiospiel/rubpubsub">github.com/radiospiel/rubpubsub</a>.
      </p>
      </div>
    </div>
    <form>
      <input id='msg' placeholder='type message here...' />
    </form>
  </div>
  <div class="right">
    <div id='log'>  </pre>
  </div>
</div>

<script type="text/javascript" charset="utf-8">
(function(user) {
  function scrollToBottom(node) {
    $(node).each( function() 
    {
       // certain browsers have a bug such that scrollHeight is too small
       // when content does not fill the client area of the element
       var scrollHeight = Math.max(this.scrollHeight, this.clientHeight);
       this.scrollTop = scrollHeight - this.clientHeight;
    });
  };
  
  var log = {
    message:  function(msg, klass) {
      $("<div class='" + klass + "'></div>").text(msg).appendTo('#log');
      scrollToBottom('#log');
    },
    info:     function(msg) { log.message(msg, "info"); },
    error:    function(msg) { log.message(msg, "error"); }
  };

  function publish(msg, channels) {
    var url = channels.length == 1 ? '/pub/' + channels[0] :
      '/pub/?channels=' + channels.join(",");
    
    $.post(url, msg)
      .success(function() { log.info("posted message"); })
      .error(function(e) { log.error("cannot post message"); });
  }

  var subscription_url = '/sub?channels=chat,' + user;

  var es = new EventSource(subscription_url);
  es.onerror = function(e)   { log.error("EventSource error"); };

  var log_event = function(event) {
    $("<div></div>").text(event.data).appendTo('#chat'); 
    scrollToBottom('#chat');
  };

  es.addEventListener(user, log_event);
  es.addEventListener('chat', log_event);
  
  function publish_chat_message(msg) {
    // Find channels from the message. A message that mentions 
    // other users via "@" gets sent only to those.
    var channels = [];
    var handles = msg.match(/@([a-z]+)/g);
    if(handles) {
      for(var i=0; i < handles.length; ++i)
        channels.push(handles[i].substr(1));
    }

    publish(user + ": " + msg, channels.length == 0 ? [ "chat" ] : channels);
  }
  
  // writing
  $("form").live("submit", function(e) {
    publish_chat_message($('#msg').val());
    
    $('#msg').val(''); $('#msg').focus();
    e.preventDefault();
  });
})(<%= user.to_json %>);
</script>

