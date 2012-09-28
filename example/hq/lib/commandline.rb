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

    url = File.join(options[:url], channel)
    URI.parse(url)
  end
  
  private
  
  SUBCOMMANDS = %w(server listen push)
  
  def parse
    return if @options

    @options = Trollop::options do
       version "hq (c) 2012 radiospiel"
        banner <<-EOS
The hq rubpubsub example application.

Usage:

  hg [ <options> ]  server
  hg [ <options> ]  pub channel command
  hg [ <options> ]  sub channel

where [options] are:

EOS

      opt :url, "Set server url", :type => String, :default => "http://localhost:9999"
      opt :port, "Set server port", :type => Integer, :default => 9999

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
