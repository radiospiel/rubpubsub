require 'eventmachine'

# Incomplete evented Redis implementation specifically made for
# the new PubSub features in Redis.
#
# See https://gist.github.com/352068
#
# Support for AUTH command added by @radiospiel 
class EventedRedis < EM::Connection
  #
  # Connect to a redis server. Supported options:
  #
  # - <b>:host</b>
  # - <b>:port</b>
  # - <b>:password</b>
  def self.connect(options)
    EM.connect options[:host], options[:port], self do |evented_redis|
      evented_redis.auth options[:password]
    end
  end
  
  # The Redis AUTH command
  def auth(password)
    call_command('auth', password) if password
  end
  
  # The Redis SUBSCRIBE command
  def subscribe(*channels, &blk)
    channels.each { |c| @blocks[c.to_s] = blk }
    call_command('subscribe', *channels)
  end
  
  # The Redis PUBLISH command
  def publish(channel, msg)
    call_command('publish', channel, msg)
  end
  
  # The Redis UNSUBSCRIBE command
  def unsubscribe
    call_command('unsubscribe')
  end
  
  private
  
  def post_init
    @blocks = {}
  end
    
  def receive_data(data)
    buffer = StringIO.new(data)
    begin
      parts = read_response(buffer)
      if parts.is_a?(Array)
        ret = @blocks[parts[1]].call(parts)
        close_connection if ret === false
      end
    end while !buffer.eof?
  end
  
  def read_response(buffer)
    type = buffer.read(1)
    case type
    when ':'
      buffer.gets.to_i
    when '*'
      size = buffer.gets.to_i
      parts = size.times.map { read_object(buffer) }
    when '-'                    # error line response
      raise buffer.read
    when '+'                    # single line response
      buffer.read
    else
      raise "unsupported response type: #{type.inspect}"
    end
  end
  
  def read_object(data)
    type = data.read(1)
    case type
    when ':' # integer
      data.gets.to_i
    when '$'
      size = data.gets
      str = data.read(size.to_i)
      data.read(2) # crlf
      str
    else
      raise "read for object of type #{type} not implemented"
    end
  end
  
  # only support multi-bulk
  def call_command(*args)
    command = "*#{args.size}\r\n"
    args.each { |a|
      command << "$#{a.to_s.size}\r\n"
      command << a.to_s
      command << "\r\n"
    }
    send_data command
  end
end
