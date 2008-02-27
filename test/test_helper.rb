require 'test/unit'
require File.dirname(__FILE__) + '/../lib/rfeedreader'

def read_feed(feed_url)
  feed = Rfeedreader.read(feed_url)
  assert_not_nil feed
  return feed
end

def read_first(feed_url)
  puts "Read first from #{feed_url}"
  feed = Rfeedreader.read_first feed_url
  unless feed.nil?
    feed.display_entries
    puts feed
  else
    puts "+++WARNING+++ nil feed"
  end
end

def read_opml(filename)
  puts "Read OPML from #{filename}"
  doc = Hpricot(open(filename))
  feeds = (doc/"outline[@htmlurl]")
  nb_feeds = feeds.size
  current_feed = 1
  feeds.each do |url|
    if current_feed > 117
      puts "Feed #{current_feed}/#{nb_feeds}"
      unless url[:xmlurl].nil?
        read_first(url[:xmlurl]) 
      else
        read_first(url[:htmlurl]) 
      end
    end
    current_feed += 1
  end
end