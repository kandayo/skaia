require "./base"

module Skaia
  module ExceptionHandler
    class Logger < Base
      Log = ::Log.for(self)

      def call(ex : Exception)
        Log.error(exception: ex) { "unhandled exception" }
      end
    end
  end
end
