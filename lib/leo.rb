require "leo/version"
require "leo/configuration"
require "leo/builder"
require "leo/logger"

module Leo
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
