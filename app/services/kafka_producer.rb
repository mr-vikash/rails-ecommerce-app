class KafkaProducer
  def self.publish(topic, message)
    producer = Rdkafka::Config.new(
      RDKAFKA_CONFIG
    ).producer

    producer.produce(
      topic: topic,
      payload: message.to_json
    )

    producer.flush
  end
end