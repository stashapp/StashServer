class MarkerModifications < ActiveRecord::Migration[5.2]
  def change
    change_table :scene_markers do |t|
      t.references :primary_tag, foreign_key: { to_table: :tags }
    end

    tag = Tag.create(name: 'PrimaryTagPlaceholder')
    SceneMarker.all.each do |scene_marker|
      scene_marker.update_attributes!(primary_tag_id: tag.id)
    end

    change_column :scene_markers, :primary_tag_id, :integer, null: false
  end
end
