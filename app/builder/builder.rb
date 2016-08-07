class Builder
  include ActiveModel::Model
  attr_accessor :doc

  def build
    @file = File.open(@doc.path, 'w+')
    add_file_header
    add_file_frontmatter
    @doc.story.chapters.order(:number).each do |chapter|
      add_chapter(chapter)
    end
    add_file_footer
    @file.close
  end

end
