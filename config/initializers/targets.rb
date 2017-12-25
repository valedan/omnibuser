yml = YAML.load(File.read(Rails.root.join('config', 'targets.yml')))
yml.each do |site|
  unless Target.where(domain: site[0]).any?
    Target.create!(domain: site[0], scraper: site[1]['scraper'], target_data: site[1]['data'])
  end
end
