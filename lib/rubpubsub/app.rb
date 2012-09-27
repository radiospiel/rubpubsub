#
# The RubPubSub subscriber rack app.
#
# This rack app is intended to be mounted via Rack::URLMap, a la
# 
#     rubpubsub = RubPubSub.new(:adapter => adapter)
#     
#     run Rack::URLMap.new({
#       "/pub"  => rubpubsub.publisher,
#       "/sub"  => rubpubsub.subscriber,
#       ...
#     })
#
class RubPubSub::App < Sinatra::Base
  attr :rubpubsub
  
  def initialize(rubpubsub, mode = :any) #:nodoc:
    expect! rubpubsub => RubPubSub, mode => [:any, :publisher, :subscriber]

    @rubpubsub = rubpubsub
    
    @publisher = [:any, :publisher].include? mode
    @subscriber = [:any, :subscriber].include? mode

    super()
  end
  
  def publisher?; @publisher; end
  def subscriber?; @subscriber; end
end

require_relative "publisher"
require_relative "subscriber"
