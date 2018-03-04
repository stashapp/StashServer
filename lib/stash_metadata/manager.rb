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

    def log(message:)
      StashMetadata.logger.info(message)
      @logs.unshift(message)
      trigger
    end

    private

      def idle
        @status = :idle
        @message = "Waiting..."
        @current = 0
        @total = 0
      end

      def trigger
        StashApiSchema.subscriptions.trigger('metadataUpdate', {}, { job_id: @job_id, message: @message, progress: progress, logs: @logs }.to_json)
      end
  end
end
