class HTMLBuilder < DocBuilder
  def add_file_header
    @file << "<!DOCTYPE html>
            <?xml version=\"1.0\" encoding=\"UTF-8\" ?>
            <html lang=\"en\">
            <head>
            <meta http-equiv=\"content-type\" content=\"application/xhtml+xml; charset=UTF-8\" >
            <title>#{@doc.story.title}</title>
            </head>
            <body>"
  end

  def add_file_frontmatter
    @file << "<h1> #{@doc.story.title}</h1>"
    @file << "<h3> <em>#{@doc.story.author}</em></h3><br>"
    @file << "<ul>"
    JSON.parse(@doc.story.meta_data).each_pair do |name, data|
      @file << "<li> <strong>#{name.capitalize}:</strong> #{data}</li> <br>"
    end
    @file << "<li> <strong>Url:</strong> #{@doc.story.url}</li> <br>"
    @file << "</ul>"
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
