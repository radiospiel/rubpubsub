module RubPubSub::MessageID
  extend self
  
  def pack_message_and_id(msg)
    id = uuid.generate
    ["#{id}:#{msg}", id]
  end

  def unpack_message_and_id(msg)
    expect! msg => /:/
    
    id, msg = msg.split(":", 2)
    [ msg, id ]
  end
  
  private
  
  def uuid
    require "uuid"
    @uuid ||= UUID.new
  end
end
