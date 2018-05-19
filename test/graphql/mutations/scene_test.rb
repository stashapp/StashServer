require 'test_helper'

class Mutations::SceneTest < ActiveSupport::TestCase

  def update(object: nil, input: {}, ctx: {})
    Mutations::SceneUpdate.field.resolve(object, input, ctx)
  end

  def create_marker(object: nil, input: {}, ctx: {})
    Mutations::SceneMarkerCreate.field.resolve(object, input, ctx)
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

  test 'create marker' do
    primary_tag = tags(:tag_9)
    other_tags = [tags(:tag_2), tags(:tag_3)]
    input = {
      scene_id: scenes(:scene).id,
      title: 'A new marker',
      seconds: 20,
      primary_tag_id: primary_tag.id,
      tag_ids: other_tags.pluck(:id)
    }

    # Ensure the marker is created
    scene_marker = create_marker(input: input)[:scene_marker]
    assert scene_marker.persisted?

    # Ensure the scene has the proper markers
    scene_marker_ids = [scene_markers(:marker).id, scene_marker.id]
    assert_equal scene_marker_ids.sort, scene_marker.scene.scene_markers.pluck(:id).sort

    # Ensure the marker has the correct number of tags
    assert_equal 2, scene_marker.tags.count

    # Ensure the primary tag lists the marker and had no other random markers
    assert_equal 1, primary_tag.primary_scene_markers.count
    assert_equal scene_marker.id, primary_tag.primary_scene_markers.first.id
    assert_equal 0, primary_tag.scene_markers.count

    # Ensure another marker is created
    scene_marker_2 = create_marker(input: input)[:scene_marker]
    assert scene_marker_2.persisted?

    # Ensure the scene has the proper markers again
    scene_marker_ids.push(scene_marker_2.id)
    assert_equal scene_marker_ids.sort, scene_marker.scene.scene_markers.pluck(:id).sort

    # Ensure both primary markers show up for a tag
    assert_equal [scene_marker.id, scene_marker_2.id], primary_tag.primary_scene_markers.pluck(:id).sort

    # Ensure adding a tag works properly
    scene_marker.add_tag('Tag 7')
    assert_equal (other_tags + [tags(:tag_7)]).pluck(:id).sort, scene_marker.tags.pluck(:id).sort

    # Make sure tag 2 has both markers
    tag2 = tags(:tag_2)
    assert_equal [scene_marker.id, scene_marker_2.id], tag2.scene_markers.pluck(:id).sort

    # Handle destruction
    scene_marker_2.destroy
    assert_equal [scene_marker.id], tag2.scene_markers.pluck(:id)

    # Invalid Marker
    input[:primary_tag_id] = nil
    assert_raises(ActiveRecord::RecordInvalid) { create_marker(input: input) }

  end
end
