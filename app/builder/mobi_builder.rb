class MOBIBuilder < DocBuilder
  def build
    epub_doc_id = @doc.story.build('epub')
    epub_doc_path = Document.find(epub_doc_id).path
    log = %x<#{Rails.root.join("lib", "kindlegen")} #{epub_doc_path} -verbose -dont_append_source >
    puts log
    Rails.logger.info(log)
  end
end
