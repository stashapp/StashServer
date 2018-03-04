require 'singleton'

module StashMetadata
  class Manager
    include Singleton

    attr_accessor :job_id, :status, :message, :logs, :current, :total

    def current=(value)
      @current = value
      trigger
    end

    def initialize
      @logs = []
      idle
    end

    def scan(job_id:)
      return unless @status == :idle
      @job_id = job_id
      @status = :scan
      @message = "Scanning..."
      @logs = []

      begin
        StashMetadata::Tasks::Scan.start
      rescue Exception => e
        raise e
      ensure
        idle
      end
    end

    def progress
      return 0 if @total == 0
      (@current / @total.to_f) * 100
    end

    # Logging

    def info(message)
      StashMetadata.logger.info(message)
      add_log(message)
    end

    def debug(message)
      StashMetadata.logger.debug(message)
      add_log(message)
    end

    def error(message)
      StashMetadata.logger.error(message)
      add_log(message)
    end

    private

      def idle
        @status = :idle
        @message = "Waiting..."
        @current = 0
        @total = 0
        trigger
      end

      def add_log(message)
        @logs.unshift(message)
        trigger
      end

      def trigger
        StashApiSchema.subscriptions.trigger('metadataUpdate', {}, { job_id: @job_id, message: @message, progress: progress, logs: @logs }.to_json)
      end
  end
end
