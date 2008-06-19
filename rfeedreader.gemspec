(in /Users/alx/dev/rfeedreader)
Gem::Specification.new do |s|
  s.name = %q{rfeedreader}
  s.version = "1.0.13"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alexandre Girard"]
  s.date = %q{2008-06-19}
  s.description = %q{Feed parser to read feed and return first posts of this feed. Special parsing from sources like Flickr, Jumcut, Google video, ...}
  s.email = %q{alx.girard@gmail.com}
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "README.txt", "website/index.txt"]
  s.files = ["History.txt", "License.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/rfeedreader.rb", "lib/rfeedreader/version.rb", "scripts/txt2html", "setup.rb", "test/test_helper.rb", "test/test_rfeedreader.rb", "website/index.html", "website/index.txt", "website/javascripts/rounded_corners_lite.inc.js", "website/stylesheets/screen.css", "website/template.rhtml"]
  s.has_rdoc = true
  s.homepage = %q{http://rfeedreader.rubyforge.org}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rfeedreader}
  s.rubygems_version = %q{1.1.1}
  s.summary = %q{Feed parser to read feed and return first posts of this feed. Special parsing from sources like Flickr, Jumcut, Google video, ...}
  s.test_files = ["test/test_helper.rb", "test/test_rfeedreader.rb"]

  s.add_dependency(%q<rfeedfinder>, [">= 0.9.0"])
  s.add_dependency(%q<htmlentities>, [">= 4.0.0"])
  s.add_dependency(%q<hpricot>, [">= 0.6"])
end
