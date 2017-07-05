# t.string "title"
# t.string "path"
# t.string "checksum"
# t.string "ownable_type"
# t.integer "ownable_id"

FactoryGirl.define do
  factory :gallery do
    title { Faker::Lorem.word }
    path { Faker::File.file_name }
    checksum { Faker::Crypto.md5 }
  end
end
