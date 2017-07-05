require 'rails_helper'

RSpec.describe 'Studios API', type: :request do
  # initialize test data
  let!(:studios) { create_list(:studio, 100) }
  let(:studio_id) { studios.first.id }

  # Test suite for GET /todos
  describe 'GET /studios' do
    # make HTTP get request before each example
    before { get '/studios?page=1&per_page=10' }

    it 'returns studios' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json['count']).to eq(studios.count)
      expect(json['data'].size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /todos/:id
  describe 'GET /studios/:id' do
    before { get "/studios/#{studio_id}" }

    context 'when the record exists' do
      it 'returns the studio' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(studio_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:studio_id) { 10000 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Studio/)
      end
    end
  end

  # Test suite for POST /todos
  describe 'POST /studios' do
    # valid payload
    let(:valid_attributes) { { name: 'A Name', url: 'http://aurl.com' } }

    context 'when the request is valid' do
      before { post '/studios', params: valid_attributes }

      it 'creates a todo' do
        expect(json['name']).to eq('A Name')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/studios', params: { url: 'http://aurl.com' } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(json['errors']['validation']['name'].first).to match(/can't be blank/)
      end
    end
  end

  # Test suite for PUT /todos/:id
  describe 'PUT /studios/:id' do
    let(:valid_attributes) { { title: 'A new title' } }

    context 'when the record exists' do
      before { put "/studios/#{studio_id}", params: valid_attributes }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  # Test suite for DELETE /todos/:id
  describe 'DELETE /studios/:id' do
    before { delete "/studios/#{studio_id}" }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end
