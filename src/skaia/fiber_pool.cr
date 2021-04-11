require "./fiber_pool/*"

module Skaia
  class FiberPool
    def initialize(@concurrency : Int32)
      @channel = Channel(->).new
      @runners = [] of FiberPool::Runner
    end

    def start
      @concurrency.times do
        @runners << FiberPool::Runner.new(@channel)
      end
    end

    def shutdown
      @runners.each do |runner|
        runner.shutdown
      end

      @channel.close
    end

    def post(&block)
      @channel.send(block)
    end
  end
end
