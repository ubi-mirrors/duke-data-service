class ErrorQueueHandler
  def message_count
    count = 0
    with_error_queue do |error_queue|
      count = error_queue.message_count
    end
    count
  end

  def messages(routing_key: nil, limit: nil)
    msgs = []
    with_error_queue do |error_queue|
      last_message = nil
      error_queue.message_count.times do |i|
        last_message = error_queue.pop(manual_ack: true)
        msgs << serialize_message(last_message) unless routing_key && 
          last_message.first[:routing_key] != routing_key
        break if limit && msgs.length == limit
      end
      error_queue.channel.nack(last_message[0].delivery_tag, true, true) if last_message
    end
    msgs
  end

  def requeue_message(id)
    message = nil
    with_error_queue do |error_queue|
      channel = error_queue.channel
      ack_tag = nil
      nack_tag = nil
      error_queue.message_count.times do |i|
        msg = error_queue.pop(manual_ack: true)
        last_message = serialize_message(msg)
        if last_message[:id] == id
          republish_message(channel, last_message)
          ack_tag = msg[0].delivery_tag
          message = last_message
          break
        else
          nack_tag = msg[0].delivery_tag
        end
      end
      channel.ack(ack_tag) if ack_tag
      channel.nack(nack_tag, true, true) if nack_tag
    end
    message
  end

  def requeue_all
    msgs = []
    with_error_queue do |error_queue|
      channel = error_queue.channel
      last_delivery_tag = nil
      begin
        error_queue.message_count.times do |i|
          msg = error_queue.pop(manual_ack: true)
          last_delivery_tag = msg[0].delivery_tag
          msgs << serialize_message(msg)
          republish_message(channel, msgs.last)
          channel.ack(last_delivery_tag)
        end
      rescue => e
        channel.nack(last_delivery_tag, true, true) if last_delivery_tag
        raise e
      end
    end
    msgs
  end

  def requeue_messages(routing_key:, limit: nil)
    msgs = []
    with_error_queue do |error_queue|
      channel = error_queue.channel
      nack_tag = nil
      error_queue.message_count.times do |i|
        msg = error_queue.pop(manual_ack: true)
        if routing_key && msg.first[:routing_key] == routing_key
          msgs << serialize_message(msg)
          republish_message(channel, msgs.last)
          channel.ack(msg.first.delivery_tag)
        else
          nack_tag = msg.first.delivery_tag
        end
        break if limit && msgs.length == limit
      end
      error_queue.channel.nack(nack_tag, true, true) if nack_tag
    end
    msgs
  end

  private

  def serialize_message(msg)
    payload = Base64.decode64(JSON.parse(msg.last)['payload'])
    {
      id: Digest::SHA256.hexdigest(payload),
      payload: payload,
      routing_key: msg.first[:routing_key]
    }
  end

  def gateway_exchange(channel)
    channel.exchange(Sneakers::CONFIG[:exchange], Sneakers::CONFIG[:exchange_options])
  end

  def republish_message(channel, msg)
    gateway_exchange(channel).publish(
      msg[:payload],
      {routing_key: msg[:routing_key]}
    )
  end

  def with_error_queue
    bunny_session.with_channel do |channel|
      error_queue = channel.queue(Sneakers::CONFIG[:retry_error_exchange], durable: true)
      yield error_queue
    end
  end

  def bunny_session
    Sneakers::CONFIG[:connection].start
  end
end
