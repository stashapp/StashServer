class ExportJob < ApplicationJob
  queue_as :default

  before_enqueue do |job|
    @manager = Stash::Manager.instance
    raise('Operation already in progress') unless @manager.status == :idle
  end

  def perform(*args)
    @manager = Stash::Manager.instance
    @manager.export(job_id: provider_job_id, rake: false)
  end
end
