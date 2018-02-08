class PreventNullSceneMarker < ActiveRecord::Migration[5.1]
  def change
    change_column_null :scene_markers, :title, false
    change_column_null :scene_markers, :seconds, false
    change_column_null :scene_markers, :scene_id, false
  end
end
