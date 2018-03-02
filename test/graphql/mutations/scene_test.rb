require 'test_helper'

class Mutations::SceneTest < ActiveSupport::TestCase

  def update(object: nil, input: {}, ctx: {})
    Mutations::SceneUpdate.field.resolve(object, input, ctx)
  end

  test 'update a single property with invalid input' do
    input = {
      id: scenes(:scene).id,
      title: 'New Title',
      nonexistant_key: 'foobar' # Shouldn't fail on nonexistant keys
    }

    scene = update(input: input)[:scene]

    assert scene.persisted?
    assert_equal 'New Title', scene.title
    assert_equal ['title', 'updated_at'].sort, scene.previous_changes.keys.sort
  end

  test 'update tags' do
    input = {
      id: scenes(:scene).id,
      tag_ids: [tags(:tag_1).id, tags(:tag_3).id]
    }

    scene = update(input: input)[:scene]

    assert scene.persisted?
    assert_equal 2, scene.tags.count
    assert_equal [tags(:tag_1).name, tags(:tag_3).name], scene.tag_list
  end

  test 'update performers' do
    input = {
      id: scenes(:scene).id,
      performer_ids: [performers(:performer).id]
    }

    scene = update(input: input)[:scene]

    assert scene.persisted?
    assert_equal 1, scene.performers.count
    assert_equal performers(:performer).name, scene.performers.first.name
  end
end
