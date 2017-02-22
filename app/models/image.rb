class Image < ApplicationRecord
  belongs_to :story
  before_create :generate_name

  def generate_name
    self.filename = SecureRandom.hex
  end

  def name
    "#{self.filename}.#{self.extension}"
  end


  def path
    "/tmp/#{self.name}"
  end

  def download(dir="/tmp")
    puts "Downloading image from AWS..."
    puts self.inspect
    open("#{dir}/#{self.name}", 'wb') do |file|
      file << open(self.aws_url).read
    end
    path
  end

  def upload
    obj = S3_BUCKET.objects["images/#{self.name}"]
    obj.write(
      file: path,
      acl: :public_read
    )
    self.update(aws_url: obj.public_url, aws_key: obj.key)
  end
end
