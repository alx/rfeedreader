require File.dirname(__FILE__) + '/test_helper.rb'

class TestRfeedreader < Test::Unit::TestCase

  def setup
  end

  def test_read_alex
    feed = read_feed("http://blog.alexgirard.com/feed/")
    puts feed
    feed.display_entries
  end

  def test_read_first
    feed = Rfeedreader.read_first("http://blog.alexgirard.com/feed/")
    feed.display_entries
    assert_equal 1, feed.entries.size
  end

  def test_read_flickr
    feed = Rfeedreader.read_first("http://flickr.com/photos/alx/")
    feed.display_entries
    assert_equal 1, feed.entries.size
  end

  def test_read_pablo
    feed = Rfeedreader.read_first("http://pablomancini.com.ar/")
    feed.display_entries
    assert_equal 1, feed.entries.size
  end

  def test_read_teketen_problem
    # 
    feed = Rfeedreader.read("http://www.eitb24.com/rss/rss-eitb24-kultura-eu.xml")
    assert_not_nil feed
    unless feed.nil?
      puts feed
      feed.display_entries
    end
    
    # 412 problem in rfeedfinder
    feed = Rfeedreader.read("http://www.arteleku.net/4.1/blog/laburrak/?feed=rss2")
    assert_not_nil feed
    unless feed.nil?
      puts feed
      feed.display_entries
    end
  end

  def test_read_from_feevy
    read_first "http://rss.jumpcut.com/rss/user?u_id=17C65AB8A6EF11DBBE093EF340157CF2"
    read_first "http://rss.jumpcut.com/rss/user?u_id=db9ec418fdaf11db8198000423cef5f6"
    read_first "http://organizandolaesperanza.blogspot.com"
    read_first "http://skblackburn.blogspot.com/"
    read_first "http://nadapersonal.blogspot.com"
    read_first "http://diariodeunadislexica.blogspot.com/"
    read_first "http://diputadodelosverdes.blogspot.com/"
    read_first "http://cinclin.blogspot.com/"
    read_first "http://claudiaramos.blogspot.com/"
    read_first "http://lacomunidad.elpais.com/krismontesinos/"
    read_first "http://www.becker-posner-blog.com/index.rdf"
    read_first "http://rss.slashdot.org/Slashdot/slashdot"
    read_first "http://planeta.lamatriz.org/feed/"
    read_first "http://edubloggers.blogspot.com/"
    read_first "http://www.twitter.com/alx/"
    read_first "http://alemama.blogspot.com"
    read_first "http://seedmagazine.com/news/atom-focus.xml"
    read_first "http://bitacora.feevy.com"
    read_first "http://www.enriquemeneses.com/"
    read_first "http://ianasagasti.blogs.com/"
    read_first "http://www.ecoperiodico.com/"
    read_first "http://bloc.balearweb.net/rss.php?summary=1"
    read_first "http://www.antoniobezanilla.com/"
    read_first "http://www.joselopezorozco.com/"
    read_first "http://www.dosdedosdefrente.com/blog/"
    read_first "http://www.deugarte.com/blog/fabbing/feed"
    read_first "http://www.papelenblanco.com/autor/sergio-fernandez/rss2.xml"
    read_first "http://sombra.lamatriz.org/"
    read_first "http://tristezza0.spaces.live.com/feed.rss"
    read_first "http://www.liberation.fr"
    read_first "http://juxtaprose.com/posts/good-web-20-critique/feed/"
    read_first "http://www.gara.net/rss/kultura"
    read_first "http://davicius.wordpress.com/feed/"
    read_first "http://www.cato-at-liberty.org/wp-rss.php" 
    read_first "http://creando.bligoo.com/"
    read_first "http://feeds.feedburner.com/37signals/beMH"
    read_first "http://www.takingitglobal.org/connections/tigblogs/feed.rss?UserID=251"
    read_first "http://www.rubendomfer.com/blog/"
    read_first "http://www.arfues.net/weblog/"
    read_first "http://www.lkstro.com/"
    read_first "http://www.lorenabetta.info"
    read_first "http://www.adesalambrar.info/"
    read_first "http://www.bufetalmeida.com/rss.xml"
    read_first "http://dreams.draxus.org/"
    read_first "http://mephisto.sobrerailes.com/"
    read_first "http://video.google.com/videosearch?hl=en&safe=off&q=the+office"
    read_first "http://voxd.blogsome.com/"
    read_first "http://blog.zvents.com/"
  end
  
  def test_read_content_encoded
    read_first "http://www.lacoctelera.com/macadamia/feeds/rss2"
  end
  
  def test_read_link_empty
    read_first "http://minijoan.vox.com/library/posts/atom.xml"
  end
  
  def test_read_type_error
    read_first "http://www0.fotolog.com/darth_fonsu/feed/main/rss20"
  end
  
  def test_read_twitter
    read_first "http://twitter.com/statuses/friends_timeline/534023.rss"
  end
  
  def test_encoding_error
    #read_first "http://www.adesalambrar.info/feed/"
    #read_first "http://nikoqueiruga.blogspot.com/"
    #Display full list, some not working
    #feed = read_feed("http://suevia.blogspot.com/")
    feed = read_feed("http://suevia.blogspot.com/")
    puts feed
    feed.display_entries
  end
  
  def test_encoded_uri
    read_first "http://news.google.it/news?hl=it&amp;ned=it&amp;q=wine&amp;ie=UTF-8&amp;output=rss"
  end
  
  def test_read_empty_entries
    read_first "http://blogs.ya.com/eltikitaka/atom.xml"
  end
  
  def test_timeout
    feed = Rfeedreader.read_first "http://www.zanorg.com/nicoshark/rss/fil_rss.xml"
    assert_nil feed
  end
  
  def test_read_picasa
    read_first "http://picasaweb.google.com/data/feed/base/user/christine.klassen?category=album&alt=rss&hl=en_GB&access=public"
  end
  
  def test_read_youtube
    read_first "http://www.youtube.com/rss/user/bideoakinfo/videos.rss"
  end
  
  def test_read_deugarte
    read_first "http://deugarte.com/"
  end
  
  def test_read_blogspot
    read_first "http://creatividadsocial.blogspot.com/"
  end
  
  def test_read_feed
    feed_url = "http://www.ambidextrousmag.org/blog/?feed=rss2"
    puts "Read first from #{feed_url}"
    feed = Rfeedreader.read_feed_first feed_url
    assert_not_nil feed
    assert_equal 1, feed.entries.size
    feed.display_entries
  end
  
  def test_title_html
    feed_url = "http://cgonzalez.info/?rss=1"
    feed = read_feed(feed_url)
    puts feed
    feed.display_entries
  end
  
  def test_bligoo
    feed_url = "http://www.blogplanta22.com/"
    feed = read_feed(feed_url)
    puts feed
    feed.display_entries
  end
  
  def test_read_codification
    read_first "http://feeds.feedburner.com/bluebbva"
  end
  
  def test_inquirer
    read_first "http://theinquirer.es/feed/"
  end
  
  def test_imified
    read_first "http://feeds.feedburner.com/imified"
  end
  
  def test_pere_opml
    read_opml File.dirname(__FILE__) + '/pere.opml'
  end
  
  def test_encoding_with_amp
    read_first " http://abladias.blogspot.com/feeds/posts/default"
  end
  
  def test_lot_of_space
    read_first "http://igandekoa.wordpress.com/feed/"
  end
  
  def test_wrongly_formatted_link
    read_first "http://snippets.dzone.com/rss/tag/R"
  end
  
  def test_title_truncate
    read_first "http://corankeando.zoomblog.com/rss.xml"
    #Rfeedreader.set_truncate_length(-1, 45)
    #Rfeedreader.read_first("http://corankeando.zoomblog.com/rss.xml").display_entries
  end
  
  def test_binema
    read_first "http://binema.com/?feed=rss2"
  end
  
  def test_bad_title_encoding
    read_first "http://www.esperanto.de/dej/aktualajhoj/rss.php?lingvo=eo"
  end
  
  def test_unrecognized_feed
    read_first "http://www.gobmenorca.com/noticies/RSS"
    #read_first "http://www.liberafolio.org/search_rss?SearchableText=&Title=&Description=&portal_type:list=News+Item&portal_type:list=Link&portal_type:list=Document&Creator=&submit=Search&sort_on=created&sort_order=reverse&review_s"
  end
  
  def test_description_length
    read_first "http://sine-die.blogspot.com/"
  end
  
  def test_bbvablogs
    read_first "http://tomasconde.bbvablogs.com/feed/"
  end
  
  def test_ul_list
    read_first "http://delong.typepad.com/sdj/rss.xml"
  end

  def test_strong
    read_first "http://elbloglamentable.es/feed/"
  end
  
  def test_refresh
    read_first "http://bloc.balearweb.net/rss.php?blogId=1681&profile=rss20"
  end
  
  def test_maria
    read_first "http://www.riberadelhuerva.com/Blog/"
  end
  
  def test_mrss
    read_first "http://www.mariabonitacoisas.com.br/home/rss/mrss"
  end
  
  def test_cocomment
    read_first "http://www.cocomment.com/blog/2720"
  end
  
  def test_commentlink
    read_first "http://acariciandolaanguila.blogspot.com/"
  end
  
  def test_orlandooo
    read_first "http://orlandooo.com/blog/"
  end
  
  def test_juan
    read_first "http://juan.urrutiaelejalde.org"
  end
  
  def test_wordpress
    read_first "http://argentin.wordpress.com/"
  end
end