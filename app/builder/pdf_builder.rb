class PDFBuilder < DocBuilder

  def build
    @template_dir = Rails.root.join("app", "templates", 'pdf')
    html_doc_path = HTMLBuilder.new(doc: @doc).build(nozip: true)
    @directory = "/tmp/#{@doc.filename}"
    @story = @doc.story
    @domain = check_domain
    render_template('filler.html.erb', 'filler.html')
    filler_path = "#{@directory}/filler.html"
    pdf = PDFKit.new(File.open("#{html_doc_path}"), margin_top: 10, margin_bottom: 10,
                                                    margin_left: 0, margin_right: 0, quiet: false,
                                                    header_html: filler_path, footer_html: filler_path)
    pdf.to_file(@doc.path)
    @doc.path
  end

end
