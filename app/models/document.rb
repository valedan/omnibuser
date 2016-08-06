class Document < ApplicationRecord
  belongs_to :story
  before_create :sanitize_filename
  after_create :build
  before_destroy :delete_file

  def sanitize_filename
    self.filename.gsub!(/[^\w]/, '_')
  end

  def path
    Rails.root.join('public', 'documents', "#{filename}.#{extension}")
  end

  def delete_file
    File.delete(self.path)
  end

  def build
    builder = case extension
    when 'html'
      HTMLBuilder
    when 'mobi'
      MOBIBuilder
    when 'epub'
      EPUBBuilder
    when 'pdf'
      PDFBuilder
    end
    builder.new(doc: self).build
  end
end
