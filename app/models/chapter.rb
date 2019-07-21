class Chapter < ApplicationRecord
  belongs_to :story
  validates :number, uniqueness: {scope: :story_id}
  after_create :ensure_title

  def epub
    nodeset = self.xhtml
    nodeset.search('img').each{|i| i['src'] = "../images/#{i['src']}"}
    content = nodeset.root.to_s
    content.gsub!('<hr/></i>', '</i><hr/>')
    content.gsub!('<hr/></b>', '</b><hr/>')
    content
  end

  def html
    nodeset = self.xhtml
    nodeset.search('img').each do |i|
       i['src'] = "files/images/#{i['src']}" unless i['src'].blank?
     end
    content = nodeset.root.to_s
    content.gsub!('<hr/></i>', '</i><hr/>')
    content.gsub!('<hr/></b>', '</b><hr/>')
    content
  end

  def xhtml
    nodeset = Nokogiri::XML(self.content)
    nodeset.search('.bbCodeSpoilerButton').each do |button|
      button.keys.each{|att| button.delete att}
      button['class'] = 'omni-spoilerTextContainer'
      button.name = 'div'
    end
    nodeset.search('.JsOnly').each{|js| js.remove}
    nodeset.search('noscript').each{|n| n.replace Nokogiri::XML.fragment(n.children)}
    nodeset.css('iframe').each do |iframe|
      url = iframe['src']&.sub(/^\/\//, '')
      if url
        url = "http://#{url}" unless url.start_with?('http')
        new_node = nodeset.create_element "a", "#{url}", href: "#{url}"
        iframe.replace new_node
      end
    end
    nodeset.search('img').each{|i| i.remove if i['src'].nil?}
    nodeset.search('span').each do |span|
      if span.children.search('div').count > 0
        span.name = 'div'
      end
    end
    nodeset.search('.AttributionLink').each{|n| n.remove}
    nodeset.search('.quoteExpand').each{|n| n.remove}
    nodeset.search('.quoteExpand .shrinker').each{|n| n.remove}
    nodeset.search('.bbCodeQuote').each{|n| n['data-page-break'] = 'avoid'}
    nodeset.search('.adv_tabs_wrapper').each{|n| n['style'] = ""}
    nodeset.search('.adv_tabs_noscript_content').each{|n| n['style'] = ""}
    nodeset.search('script').each{|s| s.remove}
    nodeset.search('table').each do |table|
      if table['border'] == '0'
        table['border'] = ''
      elsif !table['border'].blank? && table['border'] != '1'
        table['border'] = '1'
      end
      table.remove_attribute('cellspacing')
      table.remove_attribute('cellpadding')
    end
    nodeset.xpath("//*[@style]").each{|n| n['style'] = n['style'].sub('color: transparent', 'opacity: 0.5')}
    nodeset
  end

  def ensure_title
    if self.title.blank?
      self.update(title: "Chapter #{self.number}")
    end
  end

end
