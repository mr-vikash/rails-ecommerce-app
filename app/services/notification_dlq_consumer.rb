class NotificationDlqConsumer
  MAX_DLQ_RETRIES = 2

  def start
    $stdout.sync = true

    puts "DLQ consumer started..."
    puts "Waiting for DLQ events..."

    consumer = Rdkafka::Config.new(
      RDKAFKA_CONFIG.merge(
        "group.id" => "notification-dlq-workers",
        "auto.offset.reset" => "earliest",
        "enable.auto.commit" => "false"
      )
    ).consumer

    consumer.subscribe("notification-dlq")

    puts "Subscribed to notification-dlq"

    consumer.each do |message|
      begin
        event = JSON.parse(message.payload)

        puts "DLQ event received"
        puts "Payment ID: #{event["payment_id"]}"
        puts "Original error: #{event["error"]}"

        dlq_retry_count = event["dlq_retry_count"].to_i

        if dlq_retry_count >= MAX_DLQ_RETRIES
          puts "Maximum DLQ retries reached"
          puts "Message will not be reprocessed"

          commit_message(consumer, message)

          next
        end

        event["dlq_retry_count"] = dlq_retry_count + 1

        # Remove old failure information
        event.delete("error")
        event.delete("failed_at")
        event.delete("retry_count")

        KafkaProducer.publish(
          "notification-events",
          event
        )

        puts "Event re-published to notification-events"
        puts "DLQ retry count: #{event["dlq_retry_count"]}"

        commit_message(consumer, message)

      rescue JSON::ParserError => e
        puts "Invalid DLQ JSON: #{e.message}"

        commit_message(consumer, message)

      rescue StandardError => e
        puts "DLQ processing failed: #{e.message}"

        # Don't commit.
        # Kafka will redeliver the DLQ message.
      end
    end

  ensure
    consumer&.close
  end

  private

  def commit_message(consumer, message)
    offsets = Rdkafka::Consumer::TopicPartitionList.new

    offsets.add_topic_and_partitions_with_offsets(
      message.topic,
      {
        message.partition => message.offset + 1
      }
    )

    consumer.commit(offsets)

    puts "DLQ message committed successfully: " \
         "topic=#{message.topic}, " \
         "partition=#{message.partition}, " \
         "offset=#{message.offset}"
  end
end