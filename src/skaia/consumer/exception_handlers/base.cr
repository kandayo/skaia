module Skaia
  module ExceptionHandler
    abstract class Base
      abstract def call(ex : Exception)
    end
  end
end
