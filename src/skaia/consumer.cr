module Skaia
  class Consumer
    Log = ::Log.for(self)

    @channel : AMQP::Client::Channel = Skaia.connection.channel
    @queue : AMQP::Client::Queue
    @consumer_tag : String
    @name : String

    def initialize(worker)
      @consumer_tag = "PID:#{Process.pid}-ID:#{Random::Secure.hex(6)}"
      @name = worker.name
      @fiber_pool = FiberPool.new(worker.concurrency)
      @proxy = Proc(Skaia::Worker).new { worker.new }
      @queue = @channel.queue(worker.queue_name)
    end

    def start
      Log.info &.emit("up", worker: @name, queue: @queue.name)

      @fiber_pool.start

      @queue.subscribe(@consumer_tag, no_ack: false) do |msg|
        @fiber_pool.post do
          @proxy.call.work(msg)
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
