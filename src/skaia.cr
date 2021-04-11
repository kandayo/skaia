require "amqp-client"
require "log"
require "option_parser"

require "./skaia/*"

module Skaia
  REGISTERED_WORKERS = {{Skaia::Worker.includers}}

  Log = ::Log.for(self)

  @@connection : AMQP::Client::Connection?

  # Configuration for Skaia server.
  #
  # ```
  # Skaia.configure do |config|
  #   config.connection = AMQP::Client.new(ENV["CLOUDAMQP_URL"]).connect
  # end
  # ```
  def self.configure : Nil
    yield(self)
  end

  # Returns the current RabbitMQ connection.
  def self.connection : AMQP::Client::Connection
    @@connection.not_nil!
  end

  # Sets the current RabbitMQ connection.
  def self.connection=(conn) : Nil
    @@connection = conn
  end

  # Returns the Skaia version.
  def self.version
    VERSION
  end
end
