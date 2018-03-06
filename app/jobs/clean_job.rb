class CleanJob < ApplicationJob
  queue_as :default

  before_enqueue do |job|
    @manager = Stash::Manager.instance
    raise('Operation already in progress') unless @manager.status == :idle
  end

  def perform(*args)
    @manager = Stash::Manager.instance
    @manager.clean(job_id: provider_job_id, rake: false)
  end
end
