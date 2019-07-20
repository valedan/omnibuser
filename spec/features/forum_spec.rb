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

feature "Sufficient Velocity", js: true do
  let(:single_chapter) {'https://forums.sufficientvelocity.com/threads/archive-of-random-snips.32557/'}
  let(:unthreadmarked_op) {'https://forums.sufficientvelocity.com/threads/erlk%C3%B6nig-worm-au.33429/'}
  let(:large_images) {'https://forums.sufficientvelocity.com/threads/a-daughters-dedication-kancolle.33211/'}
  let(:many_threadmarks) {'https://forums.sufficientvelocity.com/threads/mauling-snarks-worm.41471/'}

  before :each do
    visit root_path
  end

  # scenario "Scraping a single-chapter story" do
  #   get_story single_chapter, extension: 'epub'
  #   expect(page).to have_content('Download')
  # end
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
  scenario "Scraping a story with many threadmarks" do
    get_story many_threadmarks, extension: 'html'
    expect(page).to have_content('Download')
  end
end

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
