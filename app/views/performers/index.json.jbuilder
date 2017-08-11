json.count @performers.total_count
json.data do
  json.array! @performers, partial: 'performers/performer', as: :performer
end
