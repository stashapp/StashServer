# t.string "title"
# t.string "details"
# t.string "url"
# t.date "date"
# t.integer "rating"
# t.string "path"
# t.string "checksum"
# t.string "size"
# t.decimal "duration", precision: 7, scale: 2
# t.string "video_codec"
# t.string "audio_codec"
# t.integer "width"
# t.integer "height"
# t.integer "studio_id"

FactoryGirl.define do
  factory :scene do
    checksum { |n| Faker::Crypto.md5 + "#{n}" }
    path { |n| Faker::File.file_name("path/to/#{n}") }
    title { Faker::Lorem.word }
    details { Faker::Lorem.paragraph }
    url { Faker::Internet.url }
  end
end
