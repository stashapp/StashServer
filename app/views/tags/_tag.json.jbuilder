json.(tag, :id, :name)
json.scene_ids tag.scenes.pluck(:id)
