# rubpubsub: A sinatra based HTTP-speaking async pubsub server backed by redis.

## Run the chat example.

    git clone rubpubsub
    bundle install
    rackup -c chat.ru
    # or: foreman start

## Deploy on heroku

    heroku apps:create
    heroku addons:add redistogo:nano
    git push heroku master
  
## Server Side Events, no Websockets.

rubpubsub uses server side events to stream events to the respective clients. Why?
Find your answer [here](http://www.html5rocks.com/en/tutorials/eventsource/basics/).

TL;DR: SSE can be deployed on Heroku, Websockets cannot (yet).

## pubsub where to?

rubpubsub potentially supports different messaging middlewares. It comes with
a redis based which uses one blocking redis connection for publishing and one for
subscriptions. This would not have been possible without Pieter Noordhuis' 
[EventedRedis](https://gist.github.com/352068). Visit Peter's github profile here: https://github.com/pietern.

