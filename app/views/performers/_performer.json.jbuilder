json.(performer, :id, :checksum, :name, :url, :twitter, :instagram, :birthdate, :ethnicity, :country, :eye_color, :height, :measurements, :fake_tits, :career_length, :tattoos, :piercings, :aliases, :favorite)
json.image_path performer_image_path(performer.id)
json.scene_ids do
  json.array! performer.scenes.pluck :id
end
