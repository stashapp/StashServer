require 'singleton'
require 'rake'
Rails.application.load_tasks

class Stash::Manager
  include Singleton

  attr_reader :job_id
  attr_reader :status
  attr_reader :message
  attr_reader :logs

  attr_accessor :current
  attr_accessor :total

  def current=(value)
    @current = value
    trigger_subscription
  end

  def initialize
    @logs = []
    idle
  end

  def import(job_id:, rake: true)
    return unless @status == :idle
    @job_id = job_id
    @status = :import
    @message = "Importing..."
    @logs = []
    @rake = rake

    try {
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke

      Stash::Tasks::Import.new.start
    }

    idle
  end

  def export(job_id:, rake: true)
    return unless @status == :idle
    @job_id = job_id
    @status = :export
    @message = "Exporting..."
    @logs = []
    @rake = rake

    try {
      Stash::Tasks::Export.new.start
    }

    idle
  end

  def scan(job_id:, rake: true)
    return unless @status == :idle
    @job_id = job_id
    @status = :scan
    @message = "Scanning..."
    @logs = []
    @rake = rake

    glob_path = File.join(Stash::STASH_DIRECTORY, "**", "*.{zip,m4v,mp4,mov,wmv}")
    scan_paths = Dir[glob_path]
    @current = 0
    @total = scan_paths.count
    info("Starting scan of #{scan_paths.count} files")
    scan_paths.each { |path|
      @current += 1
      try {
        scan_task = Stash::Tasks::Scan.new(path: path)
        scan_task.start
      }
    }

    idle
  end

  def generate(
    job_id:,
    sprites: true,
    previews: true,
    markers: true,
    transcodes: true,
    rake: true
  )
    return unless @status == :idle
    @job_id = job_id
    @status = :generate
    @message = "Generating content..."
    @logs = []
    @rake = rake

    @total = Scene.count
    Scene.all.each { |scene|
      @current += 1

      if sprites
        try {
          sprite_task = Stash::Tasks::GenerateSprite.new(scene: scene)
          sprite_task.start
        }
      end

      if previews
        try {
          preview_task = Stash::Tasks::GeneratePreview.new(scene: scene)
          preview_task.start
        }
      end

      if markers
        try {
          marker_task = Stash::Tasks::GenerateMarkers.new(scene: scene)
          marker_task.start
        }
      end

      if transcodes
        try {
          transcode_task = Stash::Tasks::GenerateTranscode.new(scene: scene)
          transcode_task.start
        }
      end
    }

    idle
  end

  def clean(job_id:, rake: true)
    return unless @status == :idle
    @job_id = job_id
    @status = :clean
    @message = "Cleaning..."
    @logs = []
    @rake = rake

    try {
      # TODO: Clean up more and add progress
      Stash::Tasks::Clean.new.start
    }

    idle
  end

  def progress
    return 0 if @total == 0
    (@current / @total.to_f) * 100
  end

  # Logging

  def info(message)
    Stash.logger.info(message)
    add_log(type: :info, message: message)
  end

  def debug(message)
    Stash.logger.debug(message)
    add_log(type: :debug, message: message)
  end

  def warn(message)
    Stash.logger.warn(message)
    add_log(type: :warn, message: message)
  end

  def error(message)
    Stash.logger.error(message)
    add_log(type: :error, message: message)
  end

  private

    def idle
      @status = :idle
      @message = "Waiting..."
      @current = 0
      @total = 0
      trigger_subscription
      @rake = true
    end

    def add_log(message)
      @logs.unshift(message)
      trigger_subscription
    end

    def trigger_subscription
      return if @rake

      payload = {
        job_id: @job_id,
        message: @message,
        progress: progress,
        logs: @logs
      }.to_json

      StashApiSchema.subscriptions.trigger('metadataUpdate', {}, payload)
    end

    def try
      yield
    rescue ScriptError => e
      error("#{e.inspect} --> #{e.backtrace.first}")
    rescue => e
      error(e.inspect)
    rescue Exception => e
      idle
      raise e
    end
end
