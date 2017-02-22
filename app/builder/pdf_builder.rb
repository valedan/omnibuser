class PDFBuilder < DocBuilder

  def build
    @template_dir = Rails.root.join("app", "templates", 'pdf')
    filler_path = "#{@template_dir}/filler.html"
    html_doc_path = HTMLBuilder.new(doc: @doc).build(nozip: true)
    pdf = PDFKit.new(File.open("#{html_doc_path}"), margin_top: 10, margin_bottom: 10,
                                                    margin_left: 0, margin_right: 0, quiet: false,
                                                    header_html: filler_path, footer_html: filler_path)
    pdf.to_file(@doc.path)
    @doc.path
  end

end
