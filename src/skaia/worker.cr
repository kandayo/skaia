module Skaia
  module Worker
    macro included
      @@concurrency : Int32 = 1

      def self.concurrency(number) : Int32
        @@concurrency = number
      end

      def self.concurrency
        @@concurrency
      end

      def concurrency : Int32
        @@concurrency
      end
    end

    macro from_queue(name)
      @@queue_name : String = {{name}}

      def self.queue_name : String
        @@queue_name
      end

      def queue_name : String
        @@queue_name
      end
    end

    abstract def queue_name : String
    abstract def work(msg)
  end
end
