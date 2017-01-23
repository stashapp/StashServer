class CreateScenes < ActiveRecord::Migration[5.0]
  def change

    # ------
    # Scenes
    # ------

    create_table :scenes do |t|
      # Scene Info
      t.string :title
      t.string :details
      t.string :url

      # Video File
      t.string :path
      t.string :checksum

      # References
      t.references :studio, index: true, foreign_key: true

      t.timestamps
    end
    add_index :scenes, :path, unique: true

    # ----------
    # Performers
    # ----------

    create_table :performers do |t|
      t.string :checksum
      t.string :name
      t.string :url

      t.timestamps
    end

    # -------------------
    # Performers / Scenes
    # -------------------

    create_table :performers_scenes, id: false do |t|
      t.belongs_to :performer, index: true
      t.belongs_to :scene, index: true
    end

  end
end
