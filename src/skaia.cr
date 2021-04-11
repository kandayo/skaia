require "amqp-client"
require "log"
require "option_parser"

require "./skaia/*"

module Skaia
  REGISTERED_WORKERS = {{Skaia::Worker.includers}}
  EXCEPTION_HANDLERS = {{Skaia::ExceptionHandler::Base.subclasses}}

  {% if flag?(:preview_mt) %}
    def self.mt? : Bool
      true
    end
  {% else %}
    def self.mt? : Bool
      false
    end
  {% end %}
end
