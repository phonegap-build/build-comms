module BuildComms
  class << self
    attr_reader :silent, :devnull, :logger

    def silent!
      @silent = true
      @devnull = Logger.new(open('/dev/null', 'w'))
    end

    def logger logger, level=:info
      Aws.config(:logger => logger, :log_level => level)
    end
  end
end
