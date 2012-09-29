# rubpubsub: a HTTP-protocol on top of redis pubsub or whatever

rubpubsub implements a HTTP API on top of a pubsub middleware. It pushes messages to clients using **Server Sent Events**, instead of, e.g. Websockets.

## Quick starts

### Run the chat example.

    git clone http://github.com/radiospiel/rubpubsub.git
    cd example/chat
    bundle install
    rackup
    # or: foreman start

### Deploy the chat example on heroku.

    git clone http://github.com/radiospiel/rubpubsub.git
    heroku apps:create
    heroku addons:add redistogo:nano
    git push heroku master

## Why Server Sent Events?

TL;DR: SSE can be deployed on Heroku, Websockets cannot (yet).

rubpubsub uses server sent events to stream events to its clients. Why?

- SSE are somewhat [standardized](http://www.w3.org/TR/eventsource/).
- There is browser support for the corresponding EventSource Javascript object 
in all major browsers except in Internet Explorer, and there is a polyfill 
for those browsers that don't come with native support.
- The SSE protocol does not need special preparation on the server stack and
in intermediate proxies, as it fully conforms to the HTTP protocol. Websockets, 
on the other hand, need WebSocket support at least on the server. For example,
as of today you cannot deploy a WebSocket-ready app behind an nginx reverse proxy,
as you cannot deploy such an app on heroku.com.

## The rubpubsub HTTP server

The rubpubsub HTTP server is a Rack application, and is intended to be installed 
via Rack tools. The following, taken from the chat.rb example, installs a rubpubsub
instance on the `/pub` and `/sub` paths, and the remaining application (`Chat`)
on "/".

    rubpubsub = RubPubSub.new(:adapter => "redis://localhost:6379/")
    run Rack::URLMap.new({
      "/pub"  => rubpubsub.publisher,
      "/sub"  => rubpubsub.subscriber,
      "/"     => Chat.new
    })

If publisher and subscriber URL paths are identical, the above simplifies to

    rubpubsub = RubPubSub.new(:adapter => "redis://localhost:6379/")
    run Rack::URLMap.new({
      "/rubpubsub"  => rubpubsub.app
      "/"           => Chat.new
    })

### The rubpubsub HTTP protocol: accept subscriptions

The rubpubsub server accepts subscriptions on its subscriber URL via a GET request.

### The rubpubsub HTTP protocol: publishing

To publish into a channel you **POST** the data to publish to either the publisher
URL with additional channels parameter (e.g. "**/pub?channels=channel1,channel2**") or
to a named channel URL, e.g. "**/pub/channel1**". The server answers with a single
line holding the message ID.

Usually the server generates a uniqe message ID. You can, however, provide a message
ID as a URL parameter, e.g. "**/pub/channel1?id=AE0F39AB-0731-4192-938B-5FFF8A8F5C3A**". 
The message ID should be globally unique; consider using UUID to generate a message id.

## The messaging middleware

rubpubsub is an HTTP speaking front for different pubsub middlewares. 
rubpubsub comes with a redis based default implementation; but it should be 
easy to add additional messaging layers.

### The redis middleware

The current version would not have been possible without Pieter Noordhuis' 
[EventedRedis](https://gist.github.com/352068). Visit Peter's github profile here: https://github.com/pietern.

## Examples and Tools

rubpubsub comes with a handful of examples.

### The chat example (example/chat)

**`chat`** is a simple, (mainly) browser-based chat application. You can also use the `hq` client
application to speak to the chat server.

### The hq example (example/hq)

**`hq`** is a ruby-bases command line client.

- **`hg server`**                   start a server
- **`hg publish channel message`**  publish a message on a channel
- **`hg subscribe channel`**        subscribe to a channel

hg also implements bidirectional communication on top of SSE.

- **`hg slave channel`**            listen to a channel, execute commands, and 
  return results through back channel.
- **`hg run channel command`**      run a command remotely on a slave listening 
  to that channel.

For more information see `hg --help`

## The unsse tool (example/unsse)

**`unsse`** is a native streaming client for server side events. It is intended to be used
with a HTTP(S)-speaking client like `curl`. The following example fetches SSE events
from http://localhost:9999/abc and runs a `received-event` command on each of the events,
passing on event type and id as parameters and the event payload on STDIN.

    curl -N -s -S http://localhost:9999/abc | ./unsse received-event %event% %id%

Note the use of the `-N` curl parameter, which puts curl into unbuffered mode.
