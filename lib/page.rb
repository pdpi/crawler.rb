require 'uri'

require 'faraday'
require 'nokogiri'

module Crawler
  class Page

    attr_accessor :url, :title, :status, :retries
    attr_accessor :links, :images, :scripts, :css

    def initialize(url)
      @url = URI url
      @title = nil
      @links = []
      @scripts = []
      @images = []
      @css = []
      @retries = 0
      @status = :new
    end

    def visit
      p @url
      resp = fetch @url
      case resp.status
      when 200..299
        @status = :visited
        content_type = resp.headers['content-type'].split(';')[0]
        raise UnparseableFileException.new(content_type) unless content_type == 'text/html'
        extract_links resp
      when 300..399
        @status = :redirect
        @links = [resp.headers['location']]
      when 400..499
        @retries += 1 
        @status = :broken
        raise CrawlException.new
      when 500..599
        @retries += 1 
        @status = :broken
        raise CrawlException.new
      end
      # if resp.headers['status']
      # end
    end

    private

    def fetch url
      Faraday.get url
    end
    def extract_links(resp)
      doc = Nokogiri::HTML resp.body
      @title = doc.css('title').children.last.text
      doc.css('a').each do |el|
        href = el['href']
        next unless href
        next if href[0] == '#'
        @links.push @url + URI.escape(href)
      end
      doc.css('script[src]').each do |el|
        src = el['src']
        next unless src
        @scripts.push src
      end
      doc.css('link[type="text/css"]').each do |el|
        href = el['href']
        next unless href
        @css.push href
      end
    end
  end

  class CrawlException < Exception
  end

  class UnparseableFileException < CrawlException
    def initialize(content_type)
      @content_type = content_type
    end

    def to_s
      "couldn't parse #{@content_type}"
    end
  end
end