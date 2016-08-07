class MOBIBuilder < DocBuilder
  def build
    html_doc_id = @doc.story.build('html')
    html_doc_path = Document.find(html_doc_id).path
    %x<#{Rails.root.join("lib", "kindlegen")} #{html_doc_path}>
  end
end
