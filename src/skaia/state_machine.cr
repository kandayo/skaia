module Skaia
  # TODO: Naive. Refactor.
  module StateMachine
    class InvalidTransitionError < Exception
    end

    enum State
      Unstarted
      Starting
      Started
      Stopping
      Stopped
    end

    FLOW = {
      State::Unstarted => [State::Starting],
      State::Starting  => [State::Started, State::Stopping, State::Stopped],
      State::Started   => [State::Stopping, State::Stopped],
      State::Stopping  => [State::Stopped],
      State::Stopped   => [] of State,
    }

    getter state : State = State::Unstarted

    def transition_to!(new_state : State)
      old_state = @state

      if FLOW[old_state]?.try(&.includes?(new_state))
        @state = new_state
      else
        raise InvalidTransitionError.new("Could not transition state via #{new_state} from #{old_state}")
      end
    end

    def unstarted?
      @state == State::Unstarted
    end

    def starting?
      @state == State::Starting
    end

    def started?
      @state == State::Started
    end

    def stopping?
      @state == State::Stopping
    end

    def stopped?
      @state == State::Stopped
    end
  end
end
