class DocBuilder
  include ActiveModel::Model
  attr_accessor :doc

  def build
    @file = File.new(@doc.path, 'w+')
    add_file_header
    add_file_frontmatter
    @doc.story.chapters.order(:number).each do |chapter|
      add_chapter(chapter)
    end
    add_file_footer
    @file.close
    @file.path
  end

end
