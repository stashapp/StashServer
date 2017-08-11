json.count @studios.total_count
json.data do
  json.array! @studios, partial: 'studios/studio', as: :studio
end
