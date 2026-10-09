class NotificationConsumer
  MAX_RETRIES = 3
  RETRY_DELAY = 2

  def start
    $stdout.sync = true

    puts "Notification consumer started..."
    puts "Waiting for notification events..."

    consumer = Rdkafka::Config.new(
      RDKAFKA_CONFIG.merge(
        "group.id" => "notification-workers",
        "auto.offset.reset" => "earliest",
        "enable.auto.commit" => "false"
      )
    ).consumer

    consumer.subscribe("notification-events")

    puts "Subscribed to notification-events"

    consumer.each do |message|
      begin
        event = JSON.parse(message.payload)

        puts "Received notification event: #{event["event"]}"

        result = process_with_retry(event)

        if result == :success || result == :dlq
          commit_message(consumer, message)
        end

      rescue JSON::ParserError => e
        puts "Invalid event JSON: #{e.message}"

        # Invalid JSON cannot be processed.
        # Commit it so the consumer does not get stuck.
        commit_message(consumer, message)

      rescue StandardError => e
        puts "Processing failed: #{e.message}"

        # Do not commit.
        # Kafka can redeliver the message.
      end
    end

  ensure
    consumer&.close
  end

  private

  # --------------------------------------------------
  # Retry processing
  # --------------------------------------------------

  def process_with_retry(event)
    attempts = 0

    begin
      attempts += 1

      puts "Processing attempt #{attempts}/#{MAX_RETRIES}"

      case event["event"]
      when "payment.success"
        handle_payment_success(event)

      else
        raise "Unknown event: #{event["event"]}"
      end

      puts "Event processed successfully"

      :success

    rescue StandardError => e
      puts "Attempt #{attempts} failed: #{e.message}"

      if attempts < MAX_RETRIES
        puts "Retrying in #{RETRY_DELAY} seconds..."

        sleep RETRY_DELAY

        retry
      end

      puts "Maximum retries reached"

      publish_to_dlq(event, e)

      :dlq
    end
  end

  # --------------------------------------------------
  # Publish failed event to DLQ
  # --------------------------------------------------

  def publish_to_dlq(event, error)
    dlq_event = event.merge(
      "retry_count" => MAX_RETRIES,
      "error" => error.message,
      "failed_at" => Time.current.iso8601
    )

    KafkaProducer.publish(
      "notification-dlq",
      dlq_event
    )

    puts "Event published to notification-dlq"
  end

  # --------------------------------------------------
  # Commit Kafka offset
  # --------------------------------------------------

  def commit_message(consumer, message)
    offsets = Rdkafka::Consumer::TopicPartitionList.new

    offsets.add_topic_and_partitions_with_offsets(
      message.topic,
      {
        message.partition => message.offset + 1
      }
    )

    consumer.commit(offsets)

    puts "Message committed successfully: " \
         "topic=#{message.topic}, " \
         "partition=#{message.partition}, " \
         "offset=#{message.offset}"
  end

  # --------------------------------------------------
  # Payment success handler
  # --------------------------------------------------

  def handle_payment_success(event)
    user = User.find_by(id: event["user_id"])

    unless user
      raise "User not found: #{event["user_id"]}"
    end

    payment = Payment.find_by(id: event["payment_id"])

    unless payment
      raise "Payment not found: #{event["payment_id"]}"
    end

    # ------------------------------------------------
    # Idempotent notification
    # ------------------------------------------------

    notification = Notification.find_or_create_by!(
      payment_id: event["payment_id"]
    ) do |new_notification|
      new_notification.user = user
      new_notification.notification_type = "payment_success"
      new_notification.title = "Payment Successful"
      new_notification.message =
        "Your payment of #{event["currency"]} #{event["amount"]} " \
        "was successful for order ##{event["order_id"]}."
    end

    puts "Notification ready: #{notification.id}"

    # ------------------------------------------------
    # Idempotent email
    # ------------------------------------------------

    if notification.email_sent_at.nil?

      PaymentMailer
        .payment_success(payment)
        .deliver_now

      notification.update!(
        email_sent_at: Time.current
      )

      puts "Payment success email sent to: #{user.email}"

    else

      puts "Payment success email already sent. Skipping email."

    end
  end
end
