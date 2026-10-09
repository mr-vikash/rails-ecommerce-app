class NotificationConsumer
  def start
    $stdout.sync = true

    puts "Notification consumer started..."
    puts "Waiting for payment events..."

    consumer = Rdkafka::Config.new(
      RDKAFKA_CONFIG.merge(
        "group.id" => "notification-workers",
        "auto.offset.reset" => "earliest",
        "enable.auto.commit" => "false"
      )
    ).consumer

    consumer.subscribe("notification-events")

    consumer.each do |message|
      event = JSON.parse(message.payload)

      puts "Received notification event: #{event["event"]}"

      case event["event"]
      when "payment.success"
        handle_payment_success(event)
      else
        puts "Unknown event: #{event["event"]}"
      end

      message
    end
  rescue JSON::ParserError => e
    puts "Invalid event JSON: #{e.message}"
  ensure
    consumer&.close
  end

  private

  def handle_payment_success(event)
    user = User.find_by(id: event["user_id"])

    unless user
      puts "User not found: #{event["user_id"]}"
      return
    end

    notification = user.notifications.create!(
      notification_type: "payment_success",
      title: "Payment Successful",
      message: "Your payment of #{event["currency"]} #{event["amount"]} was successful for order ##{event["order_id"]}."
    )

    puts "Notification created: #{notification.id}"

    payment = Payment.find_by(id: event["payment_id"])

    unless payment
      puts "Payment not found: #{event["payment_id"]}"
      return
    end

    PaymentMailer.payment_success(payment).deliver_now

    puts "Payment success email sent to: #{user.email}"
  end
end
