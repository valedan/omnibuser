FactoryGirl.define do
  factory :story do
    association :request
    url "fanfiction.net/s/5782108/"
    title "Harry Potter and the Methods of Rationality"
    author "Less Wrong"
    meta_data "{\"summary\":\"Petunia married a biochemist, and Harry grew up reading science and science fiction. Then came the Hogwarts letter, and a world of intriguing new possibilities to exploit. And new friends, like Hermione Granger, and Professor McGonagall, and Professor Quirrell... COMPLETE.\",\"info\":\"Rated: Fiction  T - English - Drama/Humor -  Harry P., Hermione G. - Chapters: 122   - Words: 661,619 - Reviews: 32,985 - Favs: 20,340 - Follows: 16,184 - Updated: 3/14/2015 - Published: 2/28/2010 - Status: Complete - id: 5782108 \"}"

    factory :ffn_story do
      url "https://www.fanfiction.net"
    end

    factory :fp_story do
      url "https://www.fictionpress.com"
    end

    factory :sv_story do
      url "https://forums.sufficientvelocity.com"
    end

    factory :sb_story do
      url "https://forums.spacebattles.com"
    end

    factory :qq_story do
      url "https://forum.questionablequesting.com"
    end
  end
end
