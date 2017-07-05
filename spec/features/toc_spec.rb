require 'rails_helper'

feature "TOCScraper", js: true do

  before :each do
    visit root_path
  end

  scenario "Scraping last 3 chapters of Worm" do
    get_story 'https://parahumans.wordpress.com', extension: 'epub', recent: true, count: 3
    expect(page).to have_content('Download')
  end
  
end
