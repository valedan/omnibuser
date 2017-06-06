require 'rails_helper'

feature "Sufficient Velocity", js: true do
  let(:single_chapter) {'https://forums.sufficientvelocity.com/threads/archive-of-random-snips.32557/'}
  let(:unthreadmarked_op) {'https://forums.sufficientvelocity.com/threads/erlk%C3%B6nig-worm-au.33429/'}
  let(:large_images) {'https://forums.sufficientvelocity.com/threads/a-daughters-dedication-kancolle.33211/'}

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
