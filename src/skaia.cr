require "amqp-client"
require "option_parser"
require "log"

require "./skaia/*"

module Skaia
  REGISTERED_WORKERS = {{Skaia::Worker.includers}}
  EXCEPTION_HANDLERS = {{Skaia::ExceptionHandler::Base.subclasses}}

  def self.mt? : Bool
    {% if flag?(:preview_mt) %}
      true
    {% else %}
      false
    {% end %}
  end
end
