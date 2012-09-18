# rubpubsub: A rack based HTTP-speaking pubsub server.

## Getting started

  git clone rubpubsub
  bundle install
  foreman start

## Deploy on heroku

  heroku apps:create
  heroku addons:add redistogo:nano
  git push heroku master
  
## Server Side Events, no Websockets.

rubpubsub uses server side events to stream events to the respective clients.

## pubsub to whom?

rubpubsub supports different messaging middlewares. rubpubsub itself comes
with two redis-based middlewares and an in-memory middleware.


The redis-based middlewares would not have been possible without Pieter Noordhuis' 
[EventedRedis](https://gist.github.com/352068). Visit Peter's github profile here: https://github.com/pietern.
