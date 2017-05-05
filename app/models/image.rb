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

  def self.run_compression_test
    #this method is not used in production and is purely for testing
    #different compression strategies during development
    input_dir = Rails.root.join("test", "images", "input")
    output_dir = Rails.root.join("test", "images", "output")

    Dir.foreach(input_dir) do |file|
      next if file == '.' || file == '..'
      input =  Rails.root.join("#{input_dir}", file).to_s
      output =  Rails.root.join("#{output_dir}", file).to_s
      image = Image.create(story_id: 202,
                           extension: input.split('.')[-1],
                           source_url: 'test',
                           cover: false,
                           filename: "#{file.split('.')[0]}_50compressed")
     if image.extension == 'gif'
       output =  Rails.root.join("#{output_dir}", image.name).to_s
       %x<#{Rails.root.join("lib", "gifsicle")} -O2 --lossy=80 #{input} -o #{output} >
     else
       i = MiniMagick::Image.open(input)
       if image.extension == 'png'
         i.background '#FFFFFF'
         i.alpha 'remove'
       end
       i.format 'jpg'
       i.quality 50
       image.update(extension: 'jpg')
       output =  Rails.root.join("#{output_dir}", image.name).to_s
       i.write output
     end
    end

  end

  def compress(background_color="#FFFFFF")
    input = "#{self.path}.temp"
    if self.extension == 'gif'
      output = self.path
      %x<#{Rails.root.join("lib", "gifsicle")} -O2 --lossy=80 #{input} -o #{output} >
    else
      image = MiniMagick::Image.open(input)
      if self.extension == 'png'
        image.background background_color
        image.alpha 'remove'
      end
      image.format 'jpg'
      if image.width > 1000
        new_width = 1000
        new_height = (image.height * new_width)/image.width
        image.resize "#{new_width}x#{new_height}"
      end
      image.quality 50
      self.update(extension: 'jpg')
      output = self.path
      image.write output
    end
  end

  def download(dir="/tmp")
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
