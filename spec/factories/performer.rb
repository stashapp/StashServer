FactoryGirl.define do
  factory :scene do
    checksum { |n| Faker::Crypto.md5 + "#{n}" }
    name { Faker::Lorem.word }
    image { Faker::Lorem.paragraph }
  end
end
