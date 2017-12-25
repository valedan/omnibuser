require 'rails_helper'
include Colorscore

describe Image do
  it { should belong_to(:story) }

  before :all do
    @story  = create(:story)
    @jpg =    create(:image, story_id: @story.id, source_url: 'url1')
    @gif =    create(:gif, story_id: @story.id, source_url: 'url2')
    @png =    create(:png, story_id: @story.id, source_url: 'url3')
    FileUtils.cp(Rails.root.join("spec", "support", "images", "dancing_banana.gif"),
                 "#{@gif.path}.temp")
    @gif.compress
    FileUtils.cp(Rails.root.join("spec", "support", "images", "lake.jpg"),
                 "#{@jpg.path}.temp")
    @jpg.compress
  end

  describe '#generate_name' do
    it "generates a random filename" do
      expect(@jpg.filename).not_to eq(@png.filename)
    end
  end

  describe '#name' do
    it "gives its own filename with extension" do
      expect(@jpg.name).to eq("#{@jpg.filename}.#{@jpg.extension}")
    end
  end

  describe '#path' do
    it "gives its path on the filesystem" do
      expect(@jpg.path).to eq("/tmp/#{@jpg.name}")
    end
  end

  describe '#compress' do
    context "gifs" do
      it "saves output to correct path" do
        expect(File.exist?(@gif.path)).to be true
      end
      it "compresses output" do
        expect(File.size(@gif.path)).to be < File.size("#{@gif.path}.temp")
      end
    end

    context "non-gif" do
      context 'png' do
        before :all do
          @white_png = @png
          @black_png = create(:png, story_id: @story.id)
          FileUtils.cp(Rails.root.join("spec", "support", "images", "dice.png"),
                       "#{@black_png.path}.temp")
          FileUtils.cp(Rails.root.join("spec", "support", "images", "dice.png"),
                      "#{@white_png.path}.temp")
          @white_png.compress
          @black_png.compress('#000000')
        end

        it "replaces alpha in png with user provided background color" do
          expect(Histogram.new(@black_png.path).scores.first[1].hex).to match('000000')
        end

        it "defaults background color to white" do
          expect(Histogram.new(@white_png.path).scores.first[1].hex).to match('ffffff')
        end

        it "converts to jpg" do
          expect(MiniMagick::Image.open(@white_png.path).data['mimeType']).to eq('image/jpeg')
        end

        it "updates extension to jpg" do
          expect(@white_png.extension).to eq('jpg')
        end
      end
      it "limits width to 1000px while maintaining aspect ratio" do
        expect(MiniMagick::Image.open(@jpg.path).data['geometry']['width']).to eq(1000)
        expect(MiniMagick::Image.open(@jpg.path).data['geometry']['height']).to eq(750)
      end
      it "compresses file" do
        expect(File.size(@jpg.path)).to be < File.size("#{@jpg.path}.temp")
      end
      it "saves file to correct path" do
        expect(@jpg.path).to eq("/tmp/#{@jpg.filename}.jpg")
      end
    end
  end

  describe 'AWS interactions', type: 'aws', speed: 'slow' do
    before :all do
      @aws_object = S3_BUCKET.objects["images/#{@jpg.name}"]
      @jpg.upload
    end
    describe '#upload' do
      it "uploads image to images folder on AWS" do
        expect(@aws_object.exists?).to be true
      end
      it "updates image record with AWS url and key" do
        expect(@jpg.aws_url).to eq(@aws_object.public_url.to_s)
        expect(@jpg.aws_key).to eq(@aws_object.key)
      end
    end

    describe '#download' do
      before :all do
        File.delete(@jpg.path)
        @download = @jpg.download
      end
      it "downloads image from AWS" do
        expect(File.exist?(@jpg.path)).to be true
      end
      it "saves to specified dir if provided" do
        Dir.mkdir('/tmp/test') unless Dir.exist?('/tmp/test')
        @jpg.download('/tmp/test')
        expect(File.exist?("/tmp/test/#{@jpg.name}")).to be true
      end
      it "returns path to file" do
        expect(@download).to eq(@jpg.path)
      end
    end
  end
end
