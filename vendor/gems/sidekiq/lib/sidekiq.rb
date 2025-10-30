require "logger"

module Sidekiq
  class << self
    attr_accessor :logger
  end

  self.logger = Logger.new($stdout)

  class Configuration
    def logger=(value)
      Sidekiq.logger = value
    end
  end

  def self.configure_server
    yield(Configuration.new)
  end

  def self.configure_client
    yield(Configuration.new)
  end
end
