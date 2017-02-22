unless Rails.env.production?
  ENV['AWS_ACCESS_KEY_ID'] = "AKIAI4JSTTKLAN6UGKLQ"
  ENV['AWS_SECRET_ACCESS_KEY'] = "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"
  ENV['S3_BUCKET_NAME'] = "omnibuser"
end
