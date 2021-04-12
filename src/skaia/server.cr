require "./state_machine"

module Skaia
  class Server
    include Skaia::StateMachine

    def initialize(@consumers : Array(Skaia::Consumer))
    end

    def start
      transition_to!(State::Starting)

      # Start each consumer in its own fiber.
      @consumers.each do |consumer|
        spawn do
          consumer.start
        end
      end

      transition_to!(State::Started)
    end

    def stop
      transition_to!(State::Stopping)

      @consumers.each(&.stop)

      transition_to!(State::Stopped)
    end
  end
end
