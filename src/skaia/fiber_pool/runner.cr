module Skaia
  class FiberPool
    class Runner
      enum Signal
        Stop
        Done
      end

      def initialize(channel : Channel(->))
        @done = Channel(Signal).new

        spawn do
          loop do
            case unit = Channel.receive_first(@done, channel)
            when Signal::Stop
              @done.send(Signal::Done)
              break
            when Proc
              unit.call
            end
          end
        end
      end

      def shutdown
        @done.send(Signal::Stop)
        @done.receive
        @done.close
      end
    end
  end
end
