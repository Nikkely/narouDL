require 'nokogiri'
require 'open-uri'
require 'json'

def openAndWrite(ncode, index)
  charset = nil
  html = open('https://ncode.syosetu.com/' + ncode + '/' + index) do | page |
    charset = page.charset
    page.read
  end

  doc = Nokogiri::HTML.parse(html, nil, charset)
  File.open("#{ncode}/#{index}p.txt", "a") do | textfile |
    textfile.puts(doc.xpath('//p[@class="novel_subtitle"]').inner_text)
    textfile.puts(doc.xpath('//div[@id="novel_honbun"]').inner_text)
  end
end

json = JSON.parser.new(open("https://api.syosetu.com/novel18api/api/?lim=20\&out=json\&word=#{URI.encode("エロ")}\&of=n-ga\&order=lengthasc").read)
hash = json.parse
hash.each do |row|
  if !row['ncode'].nil?
    ncode = row['ncode'].downcase
    num = row['general_all_no']
    Dir.mkdir(ncode, 0755) unless FileTest.exist?(ncode)
    if num > 1
      num.times do |i|
        openAndWrite(ncode, (i+1).to_s)
        sleep(1)
        p "complete #{num}/#{i}"
      end
    else
      openAndWrite(ncode, "")
      sleep(1)
      p "complete #{num}"
    end
  end
end
