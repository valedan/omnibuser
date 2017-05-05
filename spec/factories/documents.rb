FactoryGirl.define do
  factory :document do
    association :story
    filename 'generic_document'
    extension 'html'
  end
end
