require "./exception_handlers/*"

module Skaia
  module ExceptionHandler
    Log = ::Log.for(self)

    def self.call(ex : Exception)
      Skaia::EXCEPTION_HANDLERS.each do |handler|
        begin
          handler.new.call(ex)
        rescue handler_ex
          Log.error(
            exception: handler_ex,
            &.emit(
              "An error occurried while executing the exception handler",
              handler: handler.name
            )
          )
        end
      end
    end
  end
end
