#!/usr/bin/env ruby
$:<< './lib'

require 'crawler'
require 'config'

if ARGV.length == 0
  puts 'usage: crawler.rb <url>'
  exit
end

crawler = Crawler::Crawler.new ARGV[0], Config.config
crawler.crawl()
crawler.site_map()