json.count(@galleries.total_count) if defined?(@galleries.total_count)
json.data do
  json.array! @galleries, partial: 'galleries/gallery', as: :gallery
end
