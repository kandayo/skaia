require "../src/skaia"

RABBITMQ_URL = "amqp://guest:guest@rabbitmq"

class MinimalWorker
  include Skaia::Worker

  from_queue "greetings"
  concurrency 10

  def work(msg)
    puts msg.body_io.to_s
    msg.ack
  end
end

Skaia.configure do |config|
  config.connection = AMQP::Client.new(RABBITMQ_URL).connect
end

cli = Skaia::CLI.new
cli.run
