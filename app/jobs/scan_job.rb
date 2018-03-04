class ScanJob < ApplicationJob
  queue_as :default

  def before_enqueue
    raise('Operation already in progress') unless @manager.status == :idle
  end

  def perform(*args)
    @manager = StashMetadata::Manager.instance
    @manager.scan(job_id: provider_job_id)
  end
end
