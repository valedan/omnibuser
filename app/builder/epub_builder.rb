require 'zip'
include ERB::Util

class EPUBBuilder < DocBuilder
  def build
    @story = @doc.story
    @template_dir = Rails.root.join("app", "templates", 'epub')
    @input = ["mimetype", "META-INF/container.xml", "OPS/package.opf", "OPS/book/table-of-contents.xhtml",
             "OPS/book/cover.xhtml", "OPS/book/frontmatter.xhtml", "OPS/book/table-of-contents.ncx"]
    @domain = @story.domain
    create_directory_structure
    create_mimetype
    create_meta_inf_container
    add_images
    add_styles
    create_cover
    create_frontmatter
    create_content
    create_toc
    create_toc_ncx
    create_package_opf
    zip_directory
  end

  def create_directory_structure
    @directory = "/tmp/#{@doc.filename}"
    FileUtils.remove_dir(@directory) if Dir.exist?(@directory)
    Dir.mkdir(@directory)
    Dir.mkdir("#{@directory}/META-INF")
    Dir.mkdir("#{@directory}/OPS")
    Dir.mkdir("#{@directory}/OPS/book")
    Dir.mkdir("#{@directory}/OPS/css")
    Dir.mkdir("#{@directory}/OPS/images")
  end

  def create_mimetype
    render_template("mimetype", "mimetype")
  end

  def create_meta_inf_container
    render_template("META-INF/container.xml", "META-INF/container.xml")
  end

  def add_images
    @story.images.where(cover: false).each do |image|
      image.download("#{@directory}/OPS/images")
      @input << "OPS/images/#{image.name}"
    end
    FileUtils.cp("#{@template_dir}/../images/xenforo-smilies-sprite.png",
     "#{@directory}/OPS/images/xenforo-smilies-sprite.png") if @domain == 'sv' || @domain == 'sb'
  end

  def add_styles
    render_template("../css/#{@domain}.css", "OPS/css/#{@domain}.css") if @domain
    render_template("../css/epub.css", "OPS/css/main.css")
    @input << "OPS/css/#{@domain}.css" if @domain
    @input << "OPS/css/main.css"
  end

  def copy_from_template(path)
    FileUtils.cp("#{@template_dir}/#{path}", "#{@directory}/#{path}")
  end



  def create_cover
    @cover = @story.cover_image
    if @cover
      @cover.download("#{@directory}/OPS/images")
      @cover_path = "OPS/images/#{@cover.name}"
      @cover_name = @cover.name
    else
      if @domain
        name = @domain
      else
        name = 'favicon'
      end
      @cover_path = "OPS/images/#{name}.png"
      @cover_name = name
      FileUtils.cp("#{@template_dir}/../images/#{name}.png", "#{@directory}/OPS/images/#{name}.png")
    end
    render_template("OPS/book/cover.xhtml.erb", "OPS/book/cover.xhtml")
    @input << @cover_path
  end

  def create_frontmatter
    render_template("OPS/book/frontmatter.xhtml.erb", "OPS/book/frontmatter.xhtml")
  end

  def create_content
    @story.chapters.order(:number).each do |chapter|
      @chapter = chapter
      template = File.read("#{@template_dir}/OPS/book/chapter.xhtml.erb")
      filename = "Chapter_#{chapter.number.to_s.rjust(3, '0')}.xhtml"
      @input << "OPS/book/#{filename}"
      f = File.new("#{@directory}/OPS/book/#{filename}", 'w+')
      f << ERB.new(template).result(binding)
      f.close
    end
  end

  def create_toc
    render_template("OPS/book/table-of-contents.xhtml.erb", "OPS/book/table-of-contents.xhtml")
  end

  def create_toc_ncx
    render_template("OPS/book/table-of-contents.ncx.erb", "OPS/book/table-of-contents.ncx")
  end

  def create_package_opf
    render_template("OPS/package.opf.erb", "OPS/package.opf")
  end

  def zip_directory
    zip_name = "/tmp/#{@doc.filename}.epub"
    File.delete(zip_name) if File.exist?(zip_name)
    Zip::File.open(zip_name, Zip::File::CREATE) do |zipfile|
      @input.each do |filename|
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(filename, @directory + '/' + filename)
      end
      #zipfile.get_output_stream("myFile") { |os| os.write "myFile contains just this" }
    end
  end
end
