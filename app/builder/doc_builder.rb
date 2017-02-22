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

  def render_template(template_path, output_path)
    template = File.read("#{@template_dir}/#{template_path}")
    f = File.new("#{@directory}/#{output_path}", 'w+')
    f << ERB.new(template).result(binding)
    f.close
  end

  def check_domain
    if @story.url.include?('fanfiction.net')
      'ffn'
    elsif @story.url.include?('fictionpress.com')
      'fp'
    elsif @story.url.include?('forums.sufficientvelocity.com')
      'sv'
    elsif @story.url.include?('forums.spacebattles.com')
      'sb'
    elsif @story.url.include?('forum.questionablequesting.com')
      'qq'
    else
      nil
    end
  end

end
