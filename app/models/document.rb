class Document < ApplicationRecord
  belongs_to :story
  after_create :build_file
  before_destroy :delete_file

  def path
    Rails.root.join('public', 'documents', "#{filename}.#{extension}")
  end

  def delete_file
    File.delete(self.path)
  end

  def build_file
    @file = File.open(self.path, 'w+')
    add_file_header
    self.story.chapters.each do |chapter|
      add_chapter(chapter)
    end
    add_file_footer
    @file.close
  end

  def add_file_header
    @file << "<!DOCTYPE html>
            <?xml version=\"1.0\" encoding=\"UTF-8\" ?>
            <html lang=\"en\">
            <head>
            <meta http-equiv=\"content-type\" content=\"application/xhtml+xml; charset=UTF-8\" >
            <title>#{self.story.title}</title>
            <author>#{self.story.author}</author>
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
