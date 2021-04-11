module Skaia
  class Context
    property exception : Exception?

    def initialize(@message : AMQP::Client::Message, @handler : MessageHandler)
      @acked = false
      @rejected = false
    end

    def queue_name : String
      @handler.queue_name
    end

    def payload : String
      @message.body_io.to_s
    end

    def properties : AMQP::Client::Properties
      @message.properties
    end

    def headers : AMQP::Client::Table
      properties.headers
    end

    # Acknowledges the message delivery to RabbitMQ.
    def ack!
      return if acked? || rejected?

      @handler.ack!(@message)
      @acked = true
    end

    # Rejects the message delivery to RabbitMQ.
    def reject!
      return if acked? || rejected?

      @handler.reject!(@message)
      @rejected = true
    end

    # Returns true if the task failed with an exception.
    def exception? : Bool
      !exception.nil?
    end

    # Returns true if the message was acknowledged.
    def acked? : Bool
      !!@acked
    end

    # Returns true if the message was rejected.
    def rejected? : Bool
      !!@rejected
    end

    # Returns true if the message was not answered.
    def noop? : Bool
      !acked? && !rejected?
    end
  end
end
