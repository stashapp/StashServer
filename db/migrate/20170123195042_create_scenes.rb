class CreateScenes < ActiveRecord::Migration[5.1]
  def change
    # ------
    # Scenes
    # ------

    create_table :scenes do |t|
      # Scene Info
      t.string  :title
      t.string  :details
      t.string  :url
      t.date    :date
      t.integer :rating

      # Video File
      t.string :path
      t.string :checksum
      t.string :size
      t.decimal :duration, precision: 7, scale: 2
      t.string :video_codec
      t.string :audio_codec
      t.integer :width
      t.integer :height

      # References
      t.references :studio, index: true, foreign_key: true

      t.timestamps
    end
    add_index :scenes, :path, unique: true

    create_table :scene_markers do |t|
      t.string :title, null: false
      t.decimal :seconds, null: false
      t.references :scene, foreign_key: true, null: false

      t.timestamps
    end

    # ----------
    # Performers
    # ----------

    create_table :performers do |t|
      t.binary :image, limit: 2.megabytes
      t.string :checksum
      t.string :name
      t.string :url
      t.string :twitter
      t.string :instagram
      t.date   :birthdate
      t.string :ethnicity
      t.string :country
      t.string :eye_color
      t.string :height
      t.string :measurements
      t.string :fake_tits
      t.string :career_length
      t.string :tattoos
      t.string :piercings
      t.string :aliases
      t.boolean :favorite, default: false, null: false

      t.timestamps
    end

    # -------------------
    # Performers / Scenes
    # -------------------

    create_table :performers_scenes, id: false do |t|
      t.belongs_to :performer, index: true
      t.belongs_to :scene, index: true
    end

    # ----------------------
    # Galleries / Performers
    # ----------------------

    create_table :galleries_performers, id: false do |t|
      t.belongs_to :gallery, index: true
      t.belongs_to :performer, index: true
    end

    # -------
    # Studios
    # -------

    create_table :studios do |t|
      t.binary :image, limit: 1.megabytes
      t.string :checksum
      t.string :name
      t.string :url

      t.timestamps
    end

    # ----
    # Tags
    # ----

    create_table :tags do |t|
      t.string :name, index: true

      t.timestamps
    end

    # --------
    # Taggings
    # --------

    create_table :taggings do |t|
      t.references :taggable, polymorphic: true, index: true
      t.references :tag, foreign_key: true

      t.timestamps
    end

    # --------
    # Galleries
    # --------

    create_table :galleries do |t|
      t.string :title

      t.string :path
      t.string :checksum

      t.references :ownable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
