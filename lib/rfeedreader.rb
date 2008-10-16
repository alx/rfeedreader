require 'rubygems'
require 'hpricot'
require 'htmlentities'
require 'iconv'
require 'net/http'
require 'open-uri'
require 'rfeedfinder'
require 'timeout'

require 'rfeedreader/version'

module Rfeedreader
  module_function
  
  class TextyHelper
    
    def TextyHelper.clean(text, length)
      return text if text.empty?
      
      if text.index("<")
        # Strip html tags, tabs and new lines
        text.gsub!(/<.[^>]*>/, '')
        text.gsub!(/&#xD;/, '')
        # strip any comments, and if they have a newline at the end (ie. line with
        # only a comment) strip that too
        text.gsub!(/<!--(.*?)-->[\n]?/m, "")
      end
      text.gsub!(/\s{2,}|\n|\t/, ' ')
      truncate(HTMLEntities.encode_entities(text, :decimal), length) 
    end

    def TextyHelper.truncate(text="", length = 0, truncate_string = "...")
      return text if text.empty? or length < 1
      
      # Remove size of truncate string
      # and add space added by html entities
      l = length - truncate_string.length
      l += l - text[0...l].gsub(/(?:&.[^;]*;)/, " ").size
      truncated_text = text[0...l]
      
      # Avoid html entity truncation
      truncated_text.gsub!(/(&\S[^;]+)$/,  '')
      truncated_text << truncate_string if text.length > length
      
      return truncated_text
    end

    def TextyHelper.convertEncoding(text, encoding='utf-8')
      # Pre-process encoding
      unless text.nil?
        if encoding == 'utf-8'
          # Some strange caracters to handle
          text.gsub!("\342\200\042", "&ndash;")   # en-dash
          text.gsub!("\342\200\041", "&mdash;")   # em-dash
          text.gsub!("\342\200\174", "&hellip;")  # elipse
          text.gsub!("\342\200\176", "&lsquo;")   # single quote
          text.gsub!("\342\200\177", "&rsquo;")   # single quote
          text.gsub!("\342\200\230", "&rsquo;")   # single quote
          text.gsub!("\342\200\231", "&rsquo;")   # single quote
          text.gsub!("\342\200\234", "&ldquo;")   # Double quote, right
          text.gsub!("\342\200\235", "&rdquo;")   # Double quote, left
          text.gsub!("\342\200\242", ".")
          text.gsub!("\342\202\254", "&euro;");   # Euro symbol
          text.gsub!(/\S\200\S/, " ")             # every strange character send to the moon
          text.gsub!("\176", "\'")  # single quote
          text.gsub!("\177", "\'")  # single quote
          text.gsub!("\205", "-")		# ISO-Latin1 horizontal elipses (0x85)
          text.gsub!("\221", "\'")	# ISO-Latin1 left single-quote
          text.gsub!("\222", "\'")	# ISO-Latin1 right single-quote
          text.gsub!("\223", "\"")	# ISO-Latin1 left double-quote
          text.gsub!("\224", "\"")	# ISO-Latin1 right double-quote
          text.gsub!("\225", "\*")	# ISO-Latin1 bullet
          text.gsub!("\226", "-")		# ISO-Latin1 en-dash (0x96)
          text.gsub!("\227", "-")		# ISO-Latin1 em-dash (0x97)
          text.gsub!("\230", "\'")  # single quote
          text.gsub!("\231", "\'")  # single quote
          text.gsub!("\233", ">")		# ISO-Latin1 single right angle quote
          text.gsub!("\234", "\"")  # Double quote
          text.gsub!("\235", "\"")  # Double quote
          text.gsub!("\240", " ")		# ISO-Latin1 nonbreaking space
          text.gsub!("\246", "\|")	# ISO-Latin1 broken vertical bar
          text.gsub!("\255", "")	  # ISO-Latin1 soft hyphen (0xAD)
          text.gsub!("\264", "\'")	# ISO-Latin1 spacing acute
          text.gsub!("\267", "\*")	# ISO-Latin1 middle dot (0xB7)
          ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
          text = ic.iconv(text + ' ')[0..-2]
        elsif encoding == 'iso-8859-15'
          text.gsub!("&#8217;", "'") # Long horizontal bar
        end
      end

      begin
        text = Iconv.new('iso-8859-1', encoding).iconv(text)
        # Post-process encoding
        unless text.nil? or text.empty? or text.kind_of? ArgumentError
          text.gsub!(/[\240-\377]/) { |c| "&#%d;" % c[0] }
          if encoding == 'iso-8859-15'
            text.gsub!("&#8217;", "'")
          end
        end
      rescue  => err
        puts "Error while encoding: #{err} #{err.class}"
      end

      # replace pre-encoded html
      text.gsub!(/&amp;(\w+|#\d+);/, '&\1;')
      
      return text
    end
  end
  
  class Feed
    attr_accessor :feed_url, :title, :link, :charset, :entries, :is_mrss
    
    def initialize(link, hpricot_doc)
      @feed_url = link
      @entries = []
      
      read_header hpricot_doc
    end
    
    def parse_entries(hpricot_doc, nb_posts=10)
      @entries = []
      type = self.source_type
      
      # Parse each item
      (hpricot_doc/"item|entry")[0..nb_posts - 1].each do |item|
        
        if @is_mrss
          puts "is_mrss"
          @entries<<Entry_MRSS.new(item, self.charset)
        else
          case type
            when "source_flickr"
              @entries<<Entry_Flickr.new(item, self.charset)
            when "source_fotolog"
              @entries<<Entry_Fotolog.new(item, self.charset)
            when "source_google_video"
              @entries<<Entry_Google_Video.new(item, self.charset)
            when "source_jumpcut"
              @entries<<Entry_Jumpcut.new(item, self.charset)
            when "source_picasa"
              @entries<<Entry_Picasa.new(item, self.charset)
            when "source_youtube"
              @entries<<Entry_Youtube.new(item, self.charset)
            else
                @entries<<Entry.new(item, self.charset)
            end
        end
      end
    end
    
    def to_s
      "Feed #{feed_url}: title: #{title} - charset: #{charset}\n\rlink: #{link} - Entries: #{entries.size}"
    end
    
    def display_entries
      i = 0
      @entries.each do |entry|
        i += 1
        puts "#{i} - #{entry}"
      end
    end
    
    def contains_entries?
      return @entries.size > 0
    end
    
    protected
    
    def read_header(hpricot_doc)
      read_title hpricot_doc
      read_link hpricot_doc
      read_charset hpricot_doc
      read_mrss hpricot_doc
    end
    
    def read_mrss(hpricot_doc)
      media = hpricot_doc.to_s.scan(/xmlns:media=['"]?([^'"]*)['" ]/)
      media *= "" if media.is_a? Array
      @is_mrss = media == "http://search.yahoo.com/mrss/"
    end
    
    def read_charset(hpricot_doc)
      @charset = hpricot_doc.to_s.scan(/encoding=['"]?([^'"]*)['" ]/)
      @charset *= "" if @charset.is_a? Array
      @charset = @charset.to_s.downcase
      @charset = 'utf-8' if @charset.empty?
    end
    
    def read_title(hpricot_doc)
      begin
        @title = TextyHelper.convertEncoding((hpricot_doc/"//title:first").text)
      rescue
        @title = ""
      end
    end
    
    def read_link(hpricot_doc)
      begin
        @link = (hpricot_doc/"link").first.inner_text

        if @link.empty?
          element = (hpricot_doc/"link[@rel=alternate]").first
          @link = element[:href] unless element.nil?
        end

        if @link.empty?
          element = (hpricot_doc/"link").first
          @link = element[:href] unless element.nil?
        end
      rescue
        @link = ""
      end
    end

    def source_type
      return "source_flickr" if @feed_url =~ /http:\/\/api\.flickr\.com/
      return "source_fotolog" if @feed_url =~ /\.fotolog\.com/
      return "source_google_video" if @feed_url =~ /http:\/\/video\.google/
      return "source_jumpcut" if @feed_url =~ /http:\/\/rss\.jumpcut\.com/
      return "source_picasa" if @feed_url =~ /http:\/\/picasaweb\.google/
      return "source_youtube" if @feed_url =~ /http:\/\/www\.youtube\.com\/rss\//
      return ""
    end
  end
  
  class Entry
    attr_accessor :title, :link, :description, :charset, :hpricot_item
    alias :url :link
    
    TITLE_LENGTH = 45
    DESCRIPTION_LENGTH = 250
    
    def initialize(item, charset)
      @hpricot_item = item
      @charset = charset
      # Setup attributes
      read_link
      read_title
      read_description
    end
    
    # Return the rss item link
    def read_link
      @link = nil
      if link = (@hpricot_item/"link[@rel='alternate']")[0] || (@hpricot_item/"link")[0]
        @link = link.to_s.scan(/(http:\/\/.[^<\"]*)/).to_s
      end
    end
    
    def read_title
      preformatted_title = (@hpricot_item/:title).text
      if preformatted_title.index("CDATA")
        preformatted_title.gsub!(/<\/*title>/, '')
        preformatted_title.gsub!(/<\!\[CDATA\[/, '')
        preformatted_title.gsub!(/\]\]>/, '')
      end
      truncate_length = TITLE_LENGTH
      truncate_length = Rfeedreader::TITLE_LENGTH if Rfeedreader.const_defined? "TITLE_LENGTH"
      @title = TextyHelper.convertEncoding(TextyHelper.clean(preformatted_title, truncate_length), @charset)
    end
    
    def read_description
      @description = ""
      @description = (@hpricot_item/"content").text
      @description = (@hpricot_item/"content\:encoded").text if @description.empty?
      if @description.empty?
        @description = (@hpricot_item/"description|summary|[@type='text']").inner_html
        @description.gsub!(/^<!\[CDATA\[/, '')
        @description.gsub!(/\]\]>$/, '')
        @description = HTMLEntities.decode_entities(@description)
      end
      
      unless @description.empty?
        truncate_length = DESCRIPTION_LENGTH
        truncate_length = Rfeedreader::DESCRIPTION_LENGTH if Rfeedreader.const_defined? "DESCRIPTION_LENGTH"
        
        @description = TextyHelper.clean(@description, truncate_length)
        @description = TextyHelper.convertEncoding(@description, @charset)
        
        @description.gsub!("&#10;", "")
        @description.gsub!("&#13;", "")
        @description.strip!
          
        @description.gsub!(/((https?):\/\/([^\/]+)\/(\S*))/, '[<a href=\'\1\'>link</a>]')
        @description.strip!
        
      end
    end
    
    def to_s
      "Entry: title: #{@title} - link: #{@link}\n\rdescription: #{@description}"
    end
  end

  class Entry_MRSS<Entry
    def read_description
      image = @hpricot_item.search("media:thumbnail").to_s.scan(/url=['"]?([^'"]*)['" ]/).to_s
      @description = "<a href='#{@link}' class='image_link'><img src='#{image}' class='post_image'/></a>"
    end
  end
  
  class Entry_Flickr<Entry
    def read_description
      image = @hpricot_item.search("media:thumbnail").to_s.scan(/url=['"]?([^'"]*)['" ]/).to_s
      image = @hpricot_item.search("content|description").text.scan(/(http:\/\/farm.*_.\.jpg)/).to_s if image.nil? or image.empty?
      image.gsub!(/_.\.jpg/,"_t.jpg")
      @description = "<a href='#{@link}' class='image_link'><img src='#{image}' class='flickr_image'/></a><br/>"
    end
  end
  
  class Entry_Fotolog<Entry
    def read_description
      image = @hpricot_item.search("media:thumbnail").to_s.scan(/url=['"]?([^'"]*)['" ]/).to_s
      @description = "<a href='#{@link}' class='image_link'><img src='#{image}' class='post_image'/></a>"
    end
  end
  
  class Entry_Google_Video<Entry
    def read_description
      image = @hpricot_item.search("media:thumbnail").to_s.scan(/url=['"]?([^'"]*)['" ]/).to_s.gsub(/&amp;/, '&')
      @description = "<a href='#{@link}' class='image_link'><img src='#{image}' class='google_video_image' width='160px' height='160px'/></a><br/>"
    end
  end
  
  class Entry_Jumpcut<Entry
    def read_description
      image = @hpricot_item.search("description").to_s.scan(/src=['"]?([^'"]*)['" ]/).to_s
      @description = "<a href='#{@link}' class='image_link'><img src='#{image}' class='jumpcut_image' width='160px' height='120px'/></a><br/>"
    end
  end
  
  class Entry_Picasa<Entry
    def read_description
      image = @hpricot_item.search("media:thumbnail").to_s.scan(/url=['"]?([^'"]*)['" ]/).to_s
      @description = "<a href='#{@link}' class='image_link'><img src='#{image}' class='picasa_image'/></a>"
    end
  end
  
  class Entry_Youtube<Entry
    def read_description
      image = @hpricot_item.search("media:thumbnail").to_s.scan(/url=['"]?([^'"]*)['" ]/).to_s
      @description = "<a href='#{@link}' class='image_link'><img src='#{image}' class='youtube_image'/></a>"
    end
  end
  
  def read(uri, nb_posts=10, parse_entries=true)
    link = Rfeedfinder::feed(HTMLEntities.decode_entities(uri))
    read_feed(link, nb_posts, parse_entries)
  end

  def read_feed(uri, nb_posts=10, parse_entries=true)
    unless uri.nil?
      doc = open_doc(uri)
  
      unless doc.nil?
        feed = Feed.new(uri, doc)
        feed.parse_entries(doc, nb_posts) if parse_entries == true
      end
    end
    return feed
  end
  
  def read_first(uri)
    return read(uri, nb_post=1)
  end
  
  def read_feed_first(uri)
    return read(uri, nb_post=1, is_feed=true)
  end
  
  def read_header(uri)
    return read(uri, parse_entries=false)
  end
  
  def read_feed_header(uri)
    return read_feed(uri, parse_entries=false)
  end
  
  def set_truncate_length(title = -1, description = -1)
    const_set("TITLE_LENGTH", title)
    const_set("DESCRIPTION_LENGTH", description)
  end

  def open_doc(link)
    data = nil
    delay = 30
    begin
      Timeout::timeout(delay) {
        data = Hpricot(open(link,
               "User-Agent" => "Ruby/#{RUBY_VERSION} - Rfeedreader - v#{Rfeedreader::VERSION::STRING}",
               "From" => "rfeedreader@googlegroups.com",
               "Referer" => "http://rfeedreader.rubyforge.org/"), :xml => true)
      }
    rescue OpenURI::HTTPError
      begin
        Timeout::timeout(delay) {
          html = Net::HTTP.get(URI.parse(link))
          data = Hpricot(html, :xml => true) if html.to_s !~ /404 Not Found/
        }
      rescue Timeout::Error
        return nil
      rescue => err
        puts "Error while opening #{link} with Hpricot: #{err.class} " << $!
        return nil
      end
    rescue Timeout::Error 
      return nil
    rescue => err
      puts "Error while opening #{link} with Hpricot: #{err.class} " << $!
      return nil
    end
    return data
  end
end