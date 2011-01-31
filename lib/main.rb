require 'rubygems'
require 'nokogiri'
require 'open-uri'

class Asciicasts
  URL =  'http://asciicasts.com/'
  CONTAINER = "casts/"

  def initialize
    puts URL
    puts "Program iniitialized.."
    @pages_count  = get_pages_num()
    puts "scraped pages count: #{@pages_count}"
  end

  def start_scrape
    current_page = 1
    scrape_start_time = Time.now
    @pages_count.times do
      #get html for each page with links to screncasts
      Nokogiri::HTML(open(URL + "episodes/page/#{current_page}")).xpath("//ol[@class='episodeList']/li").each do |page|
        start_time = Time.now
        article_path = page.xpath("./h3/a/@href").to_s
        folder_name = article_path.split("/").last
        unless File.directory?(CONTAINER + folder_name)
          Dir.mkdir(CONTAINER + folder_name) #create a directory for html page
          article = Nokogiri::HTML(open(URL + article_path))
          #loop through all images on the page
          article.xpath("//img").each do |image|
            img_name = image.xpath("./@src").to_s.split("?").first.split("/").last
            download_image(URL + image.xpath("./@src").to_s, "#{CONTAINER + folder_name}/#{img_name}")
            #nok_article.xpath("//img/@src") = img_name
            image.set_attribute("src", img_name)
          end
          File.open("#{CONTAINER}#{folder_name}/#{folder_name}.html", "w+") do |f|
            f.write(article.to_html)
          end
          puts "#{folder_name} \t DONE! (#{Time.now - start_time} seconds)"
        else
          puts "already have this asciicast (#{folder_name})"
        end
        # puts article_html = open(URL + article_path).read
      end
      current_page = current_page + 1
    end
    puts "ALL CASTS SCRAPED SUCESSFULLY!!!!! in #{Time.now - scrape_start_time} seconds"
  end

  private

  #url - image url, filename - where to save image
  def download_image(url, filename)
    open(filename, 'wb') do |file|
      file << open(url).read
    end
  end

  def get_pages_num
    Nokogiri::HTML(open(URL)).xpath("//div[@class='pagination']/a[last()-1]").text.to_i
  end


end

as = Asciicasts.new
as.start_scrape

puts "press enter to exit.."
gets
