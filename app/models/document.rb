class Document < ApplicationRecord
  belongs_to :story
  before_create :sanitize_filename
  after_create :build
  before_destroy :delete_file

  def sanitize_filename
    self.filename.gsub!(/[^[:alpha:]]/, '_')
    self.filename.gsub!(/_{2,}/, '_')
    self.filename.gsub!(/^_/, '')
    self.filename.gsub!(/_$/, '')
    self.filename = self.filename.slice(0, 230)
    add_chapter_numbers if self.story.request.strategy == 'recent'
  end

  def add_chapter_numbers
    chapters = self.story.chapters.order(:number)
    if chapters.count == 1
      self.filename = "#{self.filename}_#{chapters.first.number}"
    else
      self.filename = "#{self.filename}_#{chapters.first.number}-#{chapters.last.number}"
    end
  end

  def path
    "/tmp/#{filename}.#{extension}"
  end

  def delete_file
    File.delete(self.path) if File.exist?(self.path)
  end

  def build
    builder = case extension
    when 'html'
      self.extension = 'zip'
      HTMLBuilder
    when 'mobi'
      MOBIBuilder
    when 'epub'
      EPUBBuilder
    when 'pdf'
      PDFBuilder
    end
    builder.new(doc: self).build
    upload
  end

  def upload
    obj = S3_BUCKET.objects["documents/#{self.filename}.#{self.extension}"]
    obj.write(
      file: path,
      acl: :public_read
    )
    self.update(aws_url: obj.public_url, aws_key: obj.key)
  end
end
