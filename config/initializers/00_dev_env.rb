unless Rails.env.production?
  ENV['AWS_ACCESS_KEY_ID'] = "placeholder"
  ENV['AWS_SECRET_ACCESS_KEY'] = "placeholder"
  ENV['S3_BUCKET_NAME'] = "omnibuser"
end
