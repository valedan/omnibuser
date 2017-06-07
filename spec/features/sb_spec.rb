require 'rails_helper'

feature "SpaceBattles", js: true do
  let(:unthreadmarked_op) {'https://forums.spacebattles.com/threads/under-your-mask-gundam-iron-blooded-orphans.463801/'}
  let(:large_images) {'https://forums.spacebattles.com/threads/ydia-ii-wild-wasteland-a-fallout-ranma-sm-cross.388980/'}

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
    expect(page).to have_content('Download')
  end
  scenario "Scraping a story with no threadmark for first post" do
    get_story unthreadmarked_op, extension: 'epub'
    expect(page).to have_content('Download')
  end
end
