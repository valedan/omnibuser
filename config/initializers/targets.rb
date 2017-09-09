if Rails.env.test?
  yml = YAML.load(File.read(Rails.root.join('config', 'targets.yml')))
  yml.each do |site|
    Target.create!(domain: site[0], scraper: site[1]['scraper'].constantize, target_data: site[1]['data'])
  end
end
