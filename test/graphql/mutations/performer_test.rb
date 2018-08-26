require 'test_helper'

class Mutations::PerformerTest < ActiveSupport::TestCase

  def create(object: nil, input: {}, ctx: {})
    Mutations::PerformerCreate.field.resolve(object, input, ctx)
  end

  def update(object: nil, input: {}, ctx: {})
    Mutations::PerformerUpdate.field.resolve(object, input, ctx)
  end

  test 'create a performer' do
    input = {
      image: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/yQALCAABAAEBAREA/8wABgAQEAX/2gAIAQEAAD8A0s8g/9k=',
      name: 'Created Performer',
      url: 'http://google.com',
      twitter: 'twitterhandle',
      instagram: 'instagramhandle',
      measurements: 'measurements',
      favorite: false
    }

    performer = create(input: input)[:performer]

    assert performer.persisted?
    assert_equal 'Created Performer', performer.name
    assert_equal 'http://google.com', performer.url
    assert_equal 'twitterhandle', performer.twitter
    assert_equal 'instagramhandle', performer.instagram
    assert_equal 'measurements', performer.measurements
  end

  test 'creating a performer with existing image fails' do
    input = {
      image: 'data:image/jpeg;base64,/9j/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/yQALCAABAAEBAREA/8wABgAQEAX/2gAIAQEAAD8A0s8g/9k=',
      name: 'Created Performer',
      favorite: false
    }

    assert_raises ActiveRecord::RecordInvalid do
      create(input: input)[:performer]
    end
  end

  test 'update a single property with invalid input' do
    input = {
      id: performers(:performer).id,
      name: 'New Performer Name',
      nonexistant_key: 'foobar' # Shouldn't fail on nonexistant keys
    }

    performer = update(input: input)[:performer]

    assert performer.persisted?
    assert_equal 'New Performer Name', performer.name
    assert_equal ['name', 'updated_at'].sort, performer.previous_changes.keys.sort
  end

end
