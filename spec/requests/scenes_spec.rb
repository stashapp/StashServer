require 'rails_helper'

RSpec.describe 'Scenes API', type: :request do
  let!(:scenes) { create_list(:scene, 100) }
  let(:scene_id) { scenes.first.id }

  describe 'GET /scenes' do
    # make HTTP get request before each example
    before { get '/scenes?page=1&per_page=10' }

    it 'returns scenes' do
      expect(json).not_to be_empty
      expect(json['count']).to eq(scenes.count)
      expect(json['data'].size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /scenes/:id' do
    before { get "/scenes/#{scene_id}" }

    context 'when the record exists' do
      it 'returns the scene' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(scene_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:scene_id) { 10000 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Scene/)
      end
    end
  end

  # Test suite for PUT /todos/:id
  describe 'PUT /scenes/:id' do
    let(:tags) { create_list(:tag, 10) }
    let(:studios) { create_list(:studio, 3) }
    let(:valid_attributes) { { title: 'A new title', studio_id: studios[1].id, tag_ids: [tags[0].id, tags[4].id] } }

    context 'when the record exists' do
      before { put "/scenes/#{scene_id}", params: valid_attributes }

      it 'updates the record' do
        expect(response.body).to be_empty

        the_scene = Scene.find(scene_id)
        expect(the_scene.tags.pluck(:id)).to match_array([tags[0].id, tags[4].id])
        expect(the_scene.studio.id).to eq(studios[1].id)
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  # # Test suite for DELETE /todos/:id
  # describe 'DELETE /scenes/:id' do
  #   before { delete "/scenes/#{studio_id}" }
  #
  #   it 'returns status code 204' do
  #     expect(response).to have_http_status(204)
  #   end
  # end
end
