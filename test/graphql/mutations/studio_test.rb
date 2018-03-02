require 'test_helper'

class Mutations::StudioTest < ActiveSupport::TestCase

  def create(object: nil, input: {}, ctx: {})
    Mutations::StudioCreate.field.resolve(object, input, ctx)
  end

  def update(object: nil, input: {}, ctx: {})
    Mutations::StudioUpdate.field.resolve(object, input, ctx)
  end

  test 'create a studio' do
    input = {
      image: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/yQALCAABAAEBAREA/8wABgAQEAX/2gAIAQEAAD8A0s8g/9k=',
      name: 'Created Studio',
    }

    studio = create(input: input)[:studio]

    assert studio.persisted?
    assert_equal 'Created Studio', studio.name
  end

  test 'update a single property with invalid input' do
    input = {
      id: studios(:studio).id,
      name: 'New Studio Name',
      nonexistant_key: 'foobar' # Shouldn't fail on nonexistant keys
    }

    studio = update(input: input)[:studio]

    assert studio.persisted?
    assert_equal 'New Studio Name', studio.name
    assert_equal ['name', 'updated_at'].sort, studio.previous_changes.keys.sort
  end

end
