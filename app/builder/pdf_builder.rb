class PDFBuilder < DocBuilder

  def build
    html_doc_id = @doc.story.build('html')
    html_doc_path = Document.find(html_doc_id).path
    pdf = PDFKit.new(File.open("#{html_doc_path}"))
    pdf.to_file(@doc.path)
    @doc.path
  end

end
