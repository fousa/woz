require "woz/version"
require "woz/configuration"
require "woz/builder"
require "woz/logger"

module Woz
  class << self
    def config
      @config ||= Configuration.default
    end

    def configure
      yield config
    end

    def run(cmd)
      puts "Executing #{cmd}"
      puts system("#{cmd}")
    end

    def logger
      @logger ||= Leo::Logger.new
    end
  end
end
