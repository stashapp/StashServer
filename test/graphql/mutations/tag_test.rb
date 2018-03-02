require 'test_helper'

class Mutations::TagTest < ActiveSupport::TestCase
  def create(object: nil, input: {}, ctx: {})
    Mutations::TagCreate.field.resolve(object, input, ctx)
  end

  def update(object: nil, input: {}, ctx: {})
    Mutations::TagUpdate.field.resolve(object, input, ctx)
  end

  test 'creating new tag' do
    input = {
      name: 'Tag Name'
    }

    tag = create(input: input)[:tag]

    assert tag.persisted?
    assert_equal 'Tag Name', tag.name
  end

  test 'update tag' do
    input = {
      id: tags(:tag_1).id,
      name: 'Tag Name Update'
    }

    tag = update(input: input)[:tag]

    assert tag.persisted?
    assert_equal 'Tag Name Update', tag.name
  end
end
