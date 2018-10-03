class IndexesAndVideoMetadata < ActiveRecord::Migration[5.2]
  def change
    # Add indexs for checksums and names
    add_index(:scenes, :checksum)
    add_index(:performers, :checksum)
    add_index(:performers, :name)
    add_index(:studios, :checksum)
    add_index(:studios, :name)

    # Add additional info to scenes
    change_table :scenes do |t|
      t.decimal :framerate, precision: 7, scale: 2
      t.integer :bitrate
    end

    Scene.all.each { |scene|
      video = FFMPEG::Movie.new(scene.path)
      scene.framerate = video.frame_rate
      scene.bitrate = video.bitrate
      scene.save!
    }
  end
end
