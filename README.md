# rubpubsub: A sinatra based HTTP-speaking async pubsub server backed by redis.

## Run the chat example.

    git clone rubpubsub
    cd example/chat
    bundle install
    rackup
    # or: foreman start

## Deploy on heroku

    heroku apps:create
    heroku addons:add redistogo:nano
    git push heroku master
  
## Server Sent Events, no Websockets.

rubpubsub uses server sent events to stream events to its clients. Why?
Find your answer [here](http://www.html5rocks.com/en/tutorials/eventsource/basics/).
As opposed to web sockets SSE don't need any special provisions on the server;
it works fine behind an nginx or apache server, and even on heroku.  

TL;DR: SSE can be deployed on Heroku, Websockets cannot (yet).

The documentation for the Server Sent Events can be found here: [http://www.w3.org/TR/eventsource/](http://www.w3.org/TR/eventsource/)

## pubsub where to?

rubpubsub is an HTTP speaking front for pubsub middleware. It comes with a
redis based default implementation; but it should be easy to add additional
messaging layers.

The current version would not have been possible without Pieter Noordhuis' 
[EventedRedis](https://gist.github.com/352068). Visit Peter's github profile here: https://github.com/pietern.
