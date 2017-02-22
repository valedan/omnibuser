PDFKit.configure do |config|
  config.wkhtmltopdf = Rails.root.join("lib", "wkhtmltopdf").to_s
  config.default_options = {
    :page_size => 'A4'
  }

end
