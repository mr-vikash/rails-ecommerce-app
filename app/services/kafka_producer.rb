class KafkaProducer
  def self.publish(topic, message)
    producer = KAFKA.producer

    producer.produce(
      message.to_json,
      topic: topic
    )

    producer.deliver_messages
  end
end