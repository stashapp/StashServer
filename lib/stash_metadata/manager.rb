require 'singleton'

module StashMetadata
  class Manager
    include Singleton

    attr_accessor :status, :message, :logs, :current, :total

    def initialize
      @logs = []
      idle
    end

    def scan
      return unless @status == :idle
      @status = :scan
      @message = "Scanning..."
      @logs = []
      Thread.new do
        begin
          StashMetadata::Tasks::Scan.start
        rescue Exception => e
        ensure
          idle
        end
      end
    end

    def progress
      return 0 if @total == 0
      (@current / @total.to_f) * 100
    end

    def log message:
      @logs.unshift(message)
    end

    private

    def idle
      @status = :idle
      @message = "Waiting..."
      @current = 0
      @total = 0
    end
  end
end
