class HTMLBuilder < Builder
  def add_file_header
    @file << "<!DOCTYPE html>
            <?xml version=\"1.0\" encoding=\"UTF-8\" ?>
            <html lang=\"en\">
            <head>
            <meta http-equiv=\"content-type\" content=\"application/xhtml+xml; charset=UTF-8\" >
            <title>#{@doc.story.title}</title>
            <author>#{@doc.story.author}</author>
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
