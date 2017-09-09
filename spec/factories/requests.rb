FactoryGirl.define do
  factory :request do
    url "https://www.fanfiction.net/s/5782108/"
    extension 'epub'
    strategy 'all'
  end
end
