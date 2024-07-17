require "httparty" 
require "nokogiri"
require 'json'
require 'base64'

# Open and read the HTML file
file_path = './files/van-gogh-paintings.html'
html_content = File.read(file_path)

# Parse the HTML content
parsed_html = Nokogiri::HTML(html_content)

img_carousel = parsed_html.css('g-scrolling-carousel')
script_tags = parsed_html.css('script')

data = { "artworks" => [] }

# Iterates each item in the carousel
img_carousel.css('a').each do |link|
    if link['aria-label']
        title = link['aria-label']
    else
        next
    end

    extensions = link.css('.ellip.klmeta').map { |element| element.text }
    image_url = "https://www.google.com#{link['href']}"
    image = link.at_css('img')
    thumbnail = nil
    image_id = image['id']

    script_tags.each do |script|
        match = /var\s+s\s*=\s*'([^']+)';\s*var\s+ii\s*=\s*\[\s*'#{image_id}'\s*\];/.match(script.content)
        if match
            thumbnail = Base64.strict_encode64(Base64.decode64(match[1]))
        end
    end      

    result = {
        "name"=> title,
        "extensions"=> extensions,
        "link"=> image_url,
        "image"=> thumbnail
    }
  
    data["artworks"] << result
end

# Writes data to JSON file
formatted_json = JSON.pretty_generate(data)
File.write('./img-extractor-output.json', formatted_json)
puts "Images extracted to img-extractor-output.json!"
