module Skaia
  module Worker
    private macro mattr_accessor(name, type, default = nil)
      {% if default %}
        @@{{name}} : {{type}} = {{default}}
      {% else %}
        @@{{name}} : {{type}}
      {% end %}

      def self.{{name}}=(value : {{type}}) : {{type}}
        @@{{name}} = value
      end

      def self.{{name}} : {{type}}
        @@{{name}}
      end
    end

    macro included
      # ```
      # self.queue_name = "greetings"
      # ```
      mattr_accessor name: queue_name,
                     type: String,
                     default: ""

      # ```
      # self.arguments["x-max-priority"] = 12
      # self.arguments["x-message-ttl"] = 5.seconds * 1000
      # ```
      mattr_accessor name: arguments,
                     type: AMQP::Client::Arguments,
                     default: AMQP::Client::Arguments.new

      # ```
      # self.durable = true
      # ```
      mattr_accessor name: durable,
                     type: Bool,
                     default: true

      # ```
      # self.concurrency = 10
      # ```
      mattr_accessor name: concurrency,
                     type: Int32,
                     default: 1

      # ```
      # self.retries = [10.seconds, 1.minute, 1.hour]
      # ```
      mattr_accessor name: retries,
                     type: Array(Int32) | Array(Time::Span),
                     default: [
                                5.seconds,
                                30.seconds,
                                1.minute,
                                10.minutes,
                                1.hour
                              ]

      Log = ::Log.for(self)
    end

    abstract def work(msg)
  end
end
