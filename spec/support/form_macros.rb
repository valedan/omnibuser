module FormMacros
  def get_story(url, recent: false, extension: nil, count: nil)
    fill_in('q', with: url)
    recent ? choose('Get most recent') : choose('Get all chapters')
    select extension, from: 'ext' if extension
    select count, from: 'recent_number' if count
    click_button 'Get'
  end
end
