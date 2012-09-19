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
  <input name='user' value='' />
  <input type='submit' value="GO!" />
</form>

@@ chat
<pre id='chat'></pre>

<script>
  // reading
  var es = new EventSource('/sub?user=<%= user %>');
  es.onmessage = function(e) { $('#chat').append(e.data + "\n"); };
  es.addEventListener('keepalive', function(e) {
    $('#chat').append("."); 
  }, false);

  // writing
  $("form").live("submit", function(e) {
    $.post('/pub', {msg: "<%= user %>: " + $('#msg').val()});
    $('#msg').val(''); $('#msg').focus();
    e.preventDefault();
  });
</script>

<form>
  <input id='msg' placeholder='type message here...' />
</form>