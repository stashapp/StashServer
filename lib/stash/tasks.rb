module Stash::Tasks
  class Base
    def initialize
      @manager = Stash::Manager.instance
    end
  end
end
