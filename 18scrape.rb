require 'nokogiri'
require 'open-uri'
require 'json'

#変更部分
query = "lim=20\&out=json\&word=#{URI.encode("異世界")}" #日本語や記号は#{URI.encode(" ")}で囲ってください
sleepSec = 1 #小数も設定可能
useTitle = false #trueならディレクトリ名が小説タイトルに
#変更部分終わり
apiUrl = "https://api.syosetu.com/novel18api/api/?minlen=1\&of=n-ga-t\&#{query}"

def openAndWrite(ncode, index, title)
  charset = nil
  html = open('https://novel18.syosetu.com/' + ncode + '/' + index, {'Cookie' =>'over18=yes'}) do | page |
    charset = page.charset
    page.read
  end
  p 'https://ncode.syosetu.com/' + ncode + '/' + index
  doc = Nokogiri::HTML.parse(html, nil, charset)
  # File.open("dl/#{title}/#{index}p.txt", "a") do | textfile |
  #   textfile.puts(doc.xpath('//p[@class="novel_subtitle"]').inner_text)
  #   textfile.puts(doc.xpath('//div[@id="novel_honbun"]').inner_text)
  # end
  puts(doc.xpath('//p[@class="novel_subtitle"]').inner_text)
  puts(doc.xpath('//div[@id="novel_honbun"]').inner_text)
end

json = JSON.parser.new(open(apiUrl).read)
hash = json.parse
hash.each do |row|
  if !row['ncode'].nil?
    ncode = row['ncode'].downcase
    num = row['general_all_no']
    title = useTitle ? row['title'] : row['ncode']
    Dir.mkdir('dl/' + title, 0755) unless FileTest.exist?('dl/' + title)
    if num > 1
      num.times do |i|
        openAndWrite(ncode, (i+1).to_s, title)
        sleep(sleepSec)
        p "complete #{ncode}(#{title}) : #{num}/#{i+1}"
      end
    else
      openAndWrite(ncode, "", title)
      sleep(sleepSec)
      p "complete #{ncode}(#{title})"
    end
  end
end
p 'complete scraping;'
