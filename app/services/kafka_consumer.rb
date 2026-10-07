class KafkaConsumer
  def start
    puts "Kafka consumer started..."
    puts "Waiting for payment events..."

    KAFKA.each_message(topic: "payment-events") do |message|
      event = JSON.parse(message.value)

      puts "Received event: #{event["event"]}"

      case event["event"]
      when "payment.captured"
        handle_payment_captured(event)
      else
        puts "Unknown event: #{event["event"]}"
      end
    end
  end

  private

  def handle_payment_captured(event)
    puts "Payment captured!"
    puts "Payment ID: #{event["payment_id"]}"
    puts "Order ID: #{event["order_id"]}"
    puts "Amount: #{event["amount"]}"
    puts "Currency: #{event["currency"]}"

    # Later we'll do:
    # - send email
    # - generate invoice
    # - notification
  end
end