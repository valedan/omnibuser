FactoryGirl.define do
  factory :image do
    cover false
    extension 'jpg'

    factory :cover_image do
      cover true
    end

    factory :gif do
      extension 'gif'
    end
    factory :png do
      extension 'png'
    end
  end
end
