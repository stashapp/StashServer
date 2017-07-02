json.count @scenes.total_count
json.data do
  json.array! @scenes, partial: 'scenes/scene', as: :scene
end
