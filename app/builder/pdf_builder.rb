include ERB::Util

class PDFBuilder < HTMLBuilder
  attr_accessor :template_dir, :input, :domain, :files

  def build
    @story = @doc.story
    @template_dir = Rails.root.join("app", "templates", 'html')
    @files = ["frontmatter"]
    @input = ["story.html"]
    @domain = @story.domain
    create_directory_structure
    add_styles
    create_cover
    add_images
    create_frontmatter
    create_content
    render_template('../pdf/filler.html.erb', 'filler.html')
    convert_to_pdf
    combine_pdfs
  end

  def create_frontmatter
    render_template("../pdf/frontmatter.html.erb", "frontmatter.html")
  end

  def create_content
    @chapters = @story.chapters.order(:number)
    index = 0
    @chapters.each_slice(10) do |chapter_chunk|
      @chapter_chunk = chapter_chunk
      index += 1
      filename = "content_#{index}"
      @files << filename
      render_template("../pdf/content.html.erb", "#{filename}.html")
    end
  end

  def convert_to_pdf
    @files.each do |filename|
      pdf = PDFKit.new(File.open("#{@directory}/#{filename}.html"),
                  margin_top: 10, margin_bottom: 10,
                  margin_left: 0, margin_right: 0, quiet: true,
                  header_html: "#{@directory}/filler.html",
                  footer_html: "#{@directory}/filler.html",
                  load_error_handling: 'ignore')
      pdf.to_file("#{@directory}/#{filename}.pdf")
    end
  end

  def combine_pdfs
    pdf = CombinePDF.new
    @files.each do |filename|
      pdf << CombinePDF.load("#{@directory}/#{filename}.pdf")
    end
    pdf.save @doc.path
  end
end
