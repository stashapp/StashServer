require 'test_helper'

class Resolvers::CreateTagTest < ActiveSupport::TestCase
  def perform(args = {})
    Resolvers::CreateTag.new.call(nil, args, {})
  end

  test 'creating new tag' do
    tag = perform(
      name: 'Tag Name'
    )

    assert tag.persisted?
    assert_equal tag.name, 'Tag Name'
  end
end
