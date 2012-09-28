require_relative "trollop"

module CommandLine
  extend self
  
  def command
    parse; @command
  end
  
  def options
    parse; @options
  end

  def uri(channel)
    require "uri"
    URI.parse url(channel)
  end

  def url(channel=nil)
    return options[:url] unless channel
    File.join(options[:url], channel)
  end
  
  private
  
  SUBCOMMANDS = %w(server publish subscribe slave run)
  
  def parse
    return if @options
  
    parse_options
    
    if options[:verbose]
      UI.verbosity = 3 
    end
    if options[:quiet]
      UI.verbosity = 0 
    end
  end
  
  def parse_options

    @options = Trollop::options do
       version "hq (c) 2012 radiospiel"
        banner <<-EOS
The hq rubpubsub example application.

Usage:

  hg [ <options> ] server
  hg [ <options> ] publish channel message
  hg [ <options> ] subscribe channel
  hg [ <options> ] slave channel
  hg [ <options> ] run channel

where [options] are:

EOS

      opt :url,  "Set server url", :default => "http://localhost:9999"
      opt :port, "Set server port", :default => 9999
      opt :id,   "Include message id in output", :default => true
      opt :verbose, "Be more verbose", :default => false
      opt :quiet, "Be quiet", :default => false
      
      stop_on SUBCOMMANDS
    end

    @command = ARGV.shift # get the subcommand

    unless SUBCOMMANDS.include?(@command)
      if @command
        Trollop.die "Unknown subcommand #{@subcommand.inspect}"
      else 
        Trollop.die "Missing subcommand"
      end
    end
  end
end
