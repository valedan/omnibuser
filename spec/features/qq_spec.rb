require 'rails_helper'

feature "Questionable Questing", js: true do
  let(:unthreadmarked_op) {'https://forum.questionablequesting.com/threads/a-prophets-portents-misc-original.2904/'}
  let(:large_images) {'https://forum.questionablequesting.com/threads/spitfire-quest-worm-x-d-d-quest-thread-1.1464/'}

  before :each do
    visit root_path
  end

  scenario "Scraping all chapters from a multi-chapter story" do
    get_story large_images, extension: 'html'
    expect(page).to have_content('Download')
  end
  scenario "Scraping one chapter from a multi-chapter story" do
    get_story large_images, extension: 'mobi', recent: true, count: 1
    expect(page).to have_content('Download')
  end
  scenario "Scraping 10 chapters from a story with fewer than 10 chapters" do
    get_story large_images, extension: 'pdf', recent: true, count: 10
    expect(page).to have_content('Download', wait: 100)
  end
  scenario "Scraping a story with no threadmark for first post" do
    get_story unthreadmarked_op, extension: 'epub'
    expect(page).to have_content('Download')
  end
end
