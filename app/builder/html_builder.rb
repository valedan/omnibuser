require 'zip'
include ERB::Util

class HTMLBuilder < DocBuilder

  def build(nozip: false)
    @story = @doc.story
    @template_dir = Rails.root.join("app", "templates", 'html')
    @input = ["story.html"]
    @domain = check_domain
    create_directory_structure
    add_styles
    create_cover
    add_images
    create_story
    if nozip
      "#{@directory}/story.html"
    else
      zip_directory
    end
  end

  def create_directory_structure
    @directory = "/tmp/#{@doc.filename}"
    FileUtils.remove_dir(@directory) if Dir.exist?(@directory)
    Dir.mkdir(@directory)
    Dir.mkdir("#{@directory}/files")
    Dir.mkdir("#{@directory}/files/css")
    Dir.mkdir("#{@directory}/files/images")

  end

  def add_styles
    render_template("../css/#{@domain}.css", "files/css/#{@domain}.css") if @domain
    render_template("../css/html.css", "files/css/main.css")
    @input << "files/css/#{@domain}.css" if @domain
    @input << "files/css/main.css"
  end

  def create_cover
    @cover = @story.cover_image
    if @cover
      @cover.download("#{@directory}/files/images")
      @cover_path = "files/images/#{@cover.name}"
      @cover_name = @cover.name
    else
      if @domain
        name = @domain
      else
        name = 'favicon'
      end
      @cover_path = "files/images/#{name}.png"
      @cover_name = name
      FileUtils.cp("#{@template_dir}/../images/#{name}.png", "#{@directory}/files/images/#{name}.png")
    end
    @input << @cover_path
  end

  def add_images
    @story.images.where(cover: false).each do |image|
      image.download("#{@directory}/files/images")
      @input << "files/images/#{image.name}"
    end
    if @domain == 'sv' || @domain == 'sb'
      FileUtils.cp("#{@template_dir}/../images/xenforo-smilies-sprite.png",
      "#{@directory}/files/images/xenforo-smilies-sprite.png")
      @input << "files/images/xenforo-smilies-sprite.png"
    end

  end

  def create_story
    render_template("story.html.erb", "story.html")
  end

  def zip_directory
    zip_name = "/tmp/#{@doc.filename}.zip"
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
