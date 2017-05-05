require 'rails_helper'
require 'fileutils'

describe DocBuilder do
  class TestBuilder < DocBuilder
    attr_accessor :template_dir, :directory
  end

  describe '#render_template' do

    before :all do
      @template_dir = '/tmp/test/template'
      @template = 'buildertest.erb'
      @directory = '/tmp/test/directory'
      @output = 'output'
      @template_path = "#{@template_dir}/#{@template}"
      @output_path = "#{@directory}/#{@output}"
      @doc = build(:document)
      builder = TestBuilder.new(doc: @doc,
                                template_dir: @template_dir, directory: @directory)
      FileUtils.rm_r('/tmp/test') if Dir.exist?('/tmp/test')
      FileUtils.mkdir(['/tmp/test', @template_dir, @directory])
      File.open(@template_path, 'w+') do |f|
        f << "<%= @doc.story.title %>"
      end
      builder.render_template(@template, @output)
    end

    it "creates a new file at the output path" do
      expect(File.exist?(@output_path)).to be true
    end
    it "renders the template into the file as ERB" do
      expect(File.read(@output_path)).to eq(@doc.story.title)
    end
  end
end
