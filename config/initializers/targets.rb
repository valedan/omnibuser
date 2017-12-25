yml = YAML.load(File.read(Rails.root.join('config', 'targets.yml')))
yml.each do |site|
  target = Target.find_by(domain: site[0])
  if target
    target.update!(scraper: site[1]['scraper'], target_data: site[1]['data'])
  else
    Target.create!(domain: site[0], scraper: site[1]['scraper'], target_data: site[1]['data'])
  end
end
