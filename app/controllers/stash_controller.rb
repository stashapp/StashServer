class StashController < ApplicationController

  def dashboard
  end

  def status
    @manager = StashMetadata::Manager.instance
  end

  def scan
    @manager = StashMetadata::Manager.instance
    @manager.scan
    head :no_content
  end

end
