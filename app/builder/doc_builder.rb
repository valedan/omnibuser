class DocBuilder
  include ActiveModel::Model
  attr_accessor :doc

  def build
    puts "builder before file open"
    @file = Tempfile.new(@doc.path, 'w+')
    puts "builder after file open"
    add_file_header
    add_file_frontmatter
    @doc.story.chapters.order(:number).each do |chapter|
      add_chapter(chapter)
    end
    add_file_footer
    puts "builder before file close"
    @file.close
    puts "builder after file close"
    @file.path
  end

end
