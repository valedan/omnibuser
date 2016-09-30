class Document < ApplicationRecord
  belongs_to :story
  before_create :sanitize_filename
  after_create :build
  before_destroy :delete_file

  def sanitize_filename
    puts "in sanitize_filename"
    self.filename.gsub!(/[^\w]/, '_')
  end

  def path
    "/tmp/#{filename}.#{extension}"
  end

  def delete_file
    File.delete(self.path) if File.exist?(self.path)
  end

  def build
    puts "build start"
    puts self.inspect
    builder = case extension
    when 'html'
      HTMLBuilder
    when 'mobi'
      MOBIBuilder
    when 'epub'
    #  EPUBBuilder
      HTMLBuilder
    when 'pdf'
      PDFBuilder
    end
    builder.new(doc: self).build
    upload
  end

  def upload
    puts "upload start"
    puts self.inspect
    puts path
    obj = S3_BUCKET.objects[self.filename]
    puts obj
    obj.write(
      file: path,
      acl: :public_read
    )
    self.update(aws_url: obj.public_url, aws_key: obj.key)
    puts "upload finish"
    puts self.inspect
  end
end
