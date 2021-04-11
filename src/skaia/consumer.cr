require "./consumer/*"

module Skaia
  class Consumer
    Log = ::Log.for(self)

    @connection : AMQP::Client::Connection
    @channel : AMQP::Client::Channel
    @queue : AMQP::Client::Queue
    @consumer_tag : String
    @name : String
    @handler : MessageHandler

    def initialize(worker, @connection : AMQP::Client::Connection)
      @consumer_tag = "PID:#{Process.pid}-ID:#{Random::Secure.hex(6)}"
      @name = worker.name
      @fiber_pool = FiberPool.new(worker.concurrency)
      @proxy = Proc(Skaia::Worker).new { worker.new }
      @channel = @connection.channel
      @queue = @channel.queue(worker.queue_name, durable: worker.durable, args: worker.arguments)
      @handler = MessageHandler.new(@channel, @queue, worker)
    end

    def start
      Log.info &.emit("up", worker: @name, queue: @queue.name)

      @fiber_pool.start

      @queue.subscribe(@consumer_tag, no_ack: false) do |msg|
        @fiber_pool.post do
          Log.with_context do
            Log.context.set(
              worker: @name,
              queue: @queue.name,
              message_id: msg.properties.message_id,
              correlation_id: msg.properties.correlation_id
            )

            ctx = Context.new(msg, @handler)

            begin
              @proxy.call.work(ctx)
            rescue ex
              Skaia::ExceptionHandler.call(ex)

              ctx.exception = ex
              ctx.reject!
            ensure
              ctx.reject! if ctx.noop?
            end
          end
        end
      end
    end

    def stop
      Log.with_context do
        Log.context.set(worker: @name, queue: @queue.name)
        Log.info { "received stop" }

        @queue.unsubscribe(@consumer_tag)
        @fiber_pool.shutdown
        @channel.close

        Log.info { "down" }
      end
    end
  end
end
