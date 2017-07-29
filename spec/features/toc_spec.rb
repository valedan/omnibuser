require 'rails_helper'

feature "TOCScraper", js: true do

  before :each do
    visit root_path
  end

  scenario "Scraping last 3 chapters of Worm" do
    get_story 'https://parahumans.wordpress.com', extension: 'epub', recent: true, count: 3
    expect(page).to have_content('Download')
  end

  scenario "Scraping last 7 chapters of Unsong" do
    get_story 'https://unsongbook.com', extension: 'pdf', recent: true, count: 7
    expect(page).to have_content('Download')
  end

  scenario "Scraping last 3 chapters of Practical Guide To Evil" do
    get_story 'https://practicalguidetoevil.wordpress.com', extension: 'mobi', recent: true, count: 3
    expect(page).to have_content('Download')
  end
end
