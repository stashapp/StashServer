class CreateScenes < ActiveRecord::Migration[5.0]
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

      # References
      t.references :studio, index: true, foreign_key: true

      t.timestamps
    end
    add_index :scenes, :path, unique: true

    # ----------
    # Performers
    # ----------

    create_table :performers do |t|
      t.binary :image, limit: 2.megabytes
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

    # -------
    # Studios
    # -------

    create_table :studios do |t|
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
