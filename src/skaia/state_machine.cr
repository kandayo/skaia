module Skaia
  module StateMachine
    {% if flag?(:preview_mt) %}
      @state_mutex = Mutex.new

      private def synchronize_state
        @state_mutex.synchronize { yield }
      end
    {% else %}
      private def synchronize_state
        yield
      end
    {% end %}

    enum State
      Pristine
      Starting
      Started
      Stopping
      Stopped
    end

    getter state : State = State::Pristine

    def transition_to(new_state : State)
      synchronize_state do
        @state = new_state
      end
    end

    def starting?
      synchronize_state do
        @state == State::Starting
      end
    end

    def started?
      synchronize_state do
        @state == State::Started
      end
    end

    def stopping?
      synchronize_state do
        @state == State::Stopping
      end
    end

    def stopped?
      synchronize_state do
        @state == State::Stopped
      end
    end
  end
end
