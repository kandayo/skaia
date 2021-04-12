module Skaia
  # Exchanges:
  #   - Retry Exchange (bound to queue.retry.DELAY_FROM_ROUTING_KEY)
  #   - Requeue Exchange (bound to queue)
  #   - Error Exchange (bound to queue.error)
  #
  # Queues:
  #   - queue
  #   - queue.retry.1000 (DLX/DLK: Requeue Exchange, TTL: 1000)
  #   - queue.retry.5000 (ditto, TTL: 5000)
  #   - queue.error
  class MessageHandler
    RETRY_EXCHANGE   = "skaia.retry"
    REQUEUE_EXCHANGE = "skaia.requeue"
    ERROR_EXCHANGE   = "skaia.error"

    Log = ::Log.for(self)

    @channel : AMQP::Client::Channel
    @queue : AMQP::Client::Queue
    @retry_exchange : AMQP::Client::Exchange
    @requeue_exchange : AMQP::Client::Exchange
    @error_exchange : AMQP::Client::Exchange
    @durable_queues : Bool
    @retry_delays : Array(Int32) | Array(Time::Span)

    def initialize(@channel, @queue, worker)
      @retry_exchange = @channel.exchange(RETRY_EXCHANGE, type: "direct")
      @requeue_exchange = @channel.exchange(REQUEUE_EXCHANGE, type: "direct")
      @error_exchange = @channel.exchange(ERROR_EXCHANGE, type: "direct")

      # Worker options.
      @durable_queues = worker.durable
      @retry_delays = worker.retries

      # Bind the requeue exchange to the main queue.
      @queue.bind(@requeue_exchange.name, routing_key: @queue.name)

      # Declare and bind each retry queue to the retry exchange.
      declare_retry_queues!

      # Declare the "morgue" queue.
      declare_error_queue!
    end

    # Acknowledges the message delivery to RabbitMQ.
    def ack!(msg : AMQP::Client::Message) : Nil
      @channel.basic_ack(msg.delivery_tag, multiple: false)
    end

    # Negatively acknowledge the message delivery to RabbitMQ.
    def nack!(msg : AMQP::Client::Message) : Nil
      retry_message(msg)
    end

    # Rejects the message delivery to RabbitMQ.
    def reject!(msg : AMQP::Client::Message) : Nil
      retry_message(msg)
    end

    private def retry_message(msg : AMQP::Client::Message, attempt = death_count(msg)) : Nil
      Log.with_context do
        Log.context.set(attempt: attempt)

        if attempt < @retry_delays.size
          Log.info { "retry" }
          @retry_exchange.publish(msg.body_io, routing_key_for(attempt), props: msg.properties)

          ack!(msg)
        else
          Log.info { "death" }
          @error_exchange.publish(msg.body_io, error_queue_name, props: msg.properties)

          reject!(msg)
        end
      end
    end

    private def death_count(msg : AMQP::Client::Message) : Int32
      return 0 unless headers = msg.properties.headers

      deaths = headers.fetch("x-death", [] of AMQ::Protocol::Table).as(Array)
      count = 0

      deaths.each do |x_death|
        count += x_death.as(AMQ::Protocol::Table)
          .fetch("count", 0)
          .as(Int64)
      end

      count
    end

    private def declare_retry_queues! : Nil
      @retry_delays.each_with_index do |delay, attempt|
        queue = @channel.queue(
          name: routing_key_for(attempt),
          durable: @durable_queues,
          args: AMQP::Client::Arguments{
            "x-dead-letter-exchange"    => REQUEUE_EXCHANGE,
            "x-dead-letter-routing-key" => @queue.name,
            "x-message-ttl"             => delay.to_i * 1000,
          }
        )

        queue.bind(RETRY_EXCHANGE, routing_key: queue.name)
      end
    end

    private def declare_error_queue! : Nil
      queue = @channel.queue(name: error_queue_name, durable: @durable_queues)
      queue.bind(ERROR_EXCHANGE, routing_key: queue.name)
    end

    private def routing_key_for(attempt) : String
      "#{@queue.name}.backoff.#{@retry_delays[attempt].to_i}"
    end

    private def error_queue_name : String
      "#{@queue.name}.error"
    end
  end
end
