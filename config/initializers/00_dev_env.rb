unless Rails.env.production?
  ENV['AWS_ACCESS_KEY_ID'] = "AKIAJA3AKCFEFCHZ477A"
  ENV['AWS_SECRET_ACCESS_KEY'] = "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"
  ENV['S3_BUCKET_NAME'] = "omnibuser"
end
