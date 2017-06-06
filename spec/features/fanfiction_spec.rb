require 'rails_helper'

feature "FanFiction", js: true do
  let(:single_chapter) {'https://www.fanfiction.net/s/3853/1/Lily-Fly-Away'}
  let(:multi_chapter)  {'https://www.fanfiction.net/s/195487/1/Bill-and-Ted-s-Adventure'}

  before :each do
    visit root_path
  end

  scenario "Scraping a single-chapter story" do
    get_story single_chapter, extension: 'epub'
    expect(page).to have_content('Download')
  end
  scenario "Scraping all chapters from a multi-chapter story" do
    get_story multi_chapter, extension: 'html'
    expect(page).to have_content('Download')
  end
  scenario "Scraping one chapter from a multi-chapter story" do
    get_story multi_chapter, extension: 'mobi', recent: true, count: 1
    expect(page).to have_content('Download')
  end
  scenario "Scraping 10 chapters from a story with fewer than 10 chapters" do
    get_story multi_chapter, extension: 'pdf', recent: true, count: 10
    expect(page).to have_content('Download')
  end
end
