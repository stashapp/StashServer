# t.string "name"
# t.string "url"

FactoryGirl.define do
  factory :studio do
    name { Faker::Lorem.word }
    url { Faker::Internet.url }
  end
end
