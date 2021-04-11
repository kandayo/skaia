require "../src/skaia"

RABBITMQ_URL = "amqp://guest:guest@rabbitmq"

class MinimalWorker
  include Skaia::Worker

  self.queue_name = "greetings"

  def work(msg)
    Log.info { msg.payload }
    msg.ack!
  end
end

class DetailedWorker
  include Skaia::Worker

  self.queue_name = "crawler"
  self.arguments["x-max-priority"] = 10
  self.concurrency = 5
  self.retries = [5.seconds, 25.seconds, 1.minute]

  def work(msg)
    Log.info { msg.payload }
    msg.ack!
  end
end

# RabbitMQ connection.
connection = AMQP::Client.new(RABBITMQ_URL).connect

Skaia::CLI.new(connection).run
