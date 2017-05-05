FactoryGirl.define do
  factory :chapter do
    association :story
    sequence(:number) {|n| n}
    title {Faker::Superhero.name}

    factory :untitled_chapter do
      title nil
    end

    factory :chapter_with_images do
      content "<div><img src=\"img1.jpg\"/>\n<img src=\"img2.jpg\"/></div>"
    end
    factory :chapter_with_srcless_images do
      content "<div><img src=\"\"/>\n<img src=\"\"/></div>"
    end
  end
end
