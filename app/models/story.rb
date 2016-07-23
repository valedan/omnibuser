class Story < ApplicationRecord
  has_many :chapters, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :requests

  def build
    filename = "#{SecureRandom.hex(8)}.html"
    filepath = Rails.root.join('public', filename)
    @file = File.open(filepath, 'w+')
    add_file_header
    self.chapters.each do |chapter|
      add_chapter(chapter)
    end
    add_file_footer
    @file.close
    filename
  end

  def add_file_header
    @file << "<!DOCTYPE html>
            <?xml version=\"1.0\" encoding=\"UTF-8\" ?>
            <html lang=\"en\">
            <head>
            <meta http-equiv=\"content-type\" content=\"application/xhtml+xml; charset=UTF-8\" >
            <title>#{self.title}</title>
            <author>#{self.author}</author>
            </head>
            <body>"
  end

  def add_chapter(chapter)
    @file << "<h1 style=\"page-break-before:always;\">#{chapter.title}</h1>"
    @file << "#{chapter.content}"
  end

  def add_file_footer
    @file << "</body>
              </html>"
  end
end
