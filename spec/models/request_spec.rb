require 'rails_helper'

describe Request do
  it { should belong_to(:story) }
end
