class EPUBBuilder < DocBuilder
  def build
    html_doc_id = @doc.story.build('html')
    html_doc_path = Document.find(html_doc_id).path
    %x<#{Rails.root.join("lib", "pandoc")} #{html_doc_path} -f html -t epub -s -o #{@doc.path}>
  end
end
