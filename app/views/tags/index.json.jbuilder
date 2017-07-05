json.count @tags.total_count
json.data do
  json.array! @tags, partial: 'tags/tag', as: :tag
end
