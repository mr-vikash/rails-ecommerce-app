class RdkafkaConsumer
  def start
    $stdout.sync = true

    puts "Rdkafka consumer started..."
    puts "Waiting for payment events..."

    consumer = Rdkafka::Config.new(
      RDKAFKA_CONFIG.merge(
        "group.id" => "payment-workers",
        "auto.offset.reset" => "earliest",
        "enable.auto.commit" => "true"
      )
    ).consumer

    consumer.subscribe("payment-events")

    puts "Subscribed to payment-events"

    consumer.each do |message|
      puts "MESSAGE RECEIVED"

      event = JSON.parse(message.payload)

      puts "Received event: #{event["event"]}"

      case event["event"]
      when "payment.captured"
        handle_payment_captured(event)
      else
        puts "Unknown event: #{event["event"]}"
      end
    end
  ensure
    consumer&.close
  end

  private

  def handle_payment_captured(event)
    puts "Payment captured!"
    puts "Payment ID: #{event["payment_id"]}"
    puts "Order ID: #{event["order_id"]}"
    puts "Amount: #{event["amount"]}"
    puts "Currency: #{event["currency"]}"

    notification_event = {
      event: "payment.success",
      user_id: event["user_id"],
      payment_id: event["payment_id"],
      order_id: event["order_id"],
      amount: event["amount"],
      currency: event["currency"]
    }

    KafkaProducer.publish(
      "notification-events",
      notification_event
    )

    puts "Notification event published!"
  end
end
