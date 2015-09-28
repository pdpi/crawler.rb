
require 'page'
require 'colorize'

module Crawler
  class Crawler
    def initialize(root, config)
      @queue = [root]
      @pages = {}
      @scope = URI(root).host
      @accept_subdomains = config['accept_subdomains']
      @interval = config['interval']
      @max_retries = config['max_retries']
    end

    # Crawl the page
    def crawl
      while @queue.length > 0
        next_queue = []
        @queue.each do |url|
          begin
            if should_visit? url
              page = visit url
              next_queue += page.links
              # throttle requests to avoid hammering the server
              sleep @interval
            end
          rescue CrawlException
            # It's safe to blindly readd the page to the queue, as the
            # page keeps track of its retries, and we test for retries
            # when determining whether to visit the page.
            next_queue += [url]
          end
        end
        @queue = next_queue
        if @pages.length > 10
          puts @pages.length
          @queue = []
        end
      end
    end

    # Render a text representation of the site map
    def site_map
      @pages.each do |url, page|
        if page.title
          puts "#{page.url} (#{page.title})".light_white.bold
        else
          puts "#{page.url}".light_white.bold
        end
        case page.status
        when :broken
          puts "  Broken Link".red
        when :redirect
          puts " Redirect to #{page.links[0]}".green
        else
          list_values page, 'Links', :links
          list_values page, 'Scripts', :scripts
          list_values page, 'Stylesheets', :css
          list_values page, 'Images', :images
        end

      end
    end

    private

    def list_values(page, key, method)
      vals = page.send method
        if vals.length > 0
          puts "  #{key}:".light_yellow
          vals.each do |val|
            puts "  ○ #{val}"
          end
        end
    end

    # Visit a URL
    def visit url
      page = (@pages[url.to_s] ||= Page.new url)
      begin
        page.visit()
      rescue UnparseableFileException
        # do nothing
      end
      page
    end

    # Determine whether we should visit a URL.
    # We don't want to visit pages that have already been successfully scanned, nor
    # do we want to insist on visiting pages that error out beyond our retry threshold.
    def should_visit?(url)
      if in_scope? url
        page = @pages[url.to_s]
        if page and (page.status == :visited or page.retries >= @max_retries)
          false 
        else
          true
        end
      else
        false
      end
    end

    # Test whether a URI is in-scope for crawling.
    # "In-scope" means that either the domain matches exactly (by default),
    # or that the domain is a subdomain of the domain for the original page,
    # if the crawler is configured to accept subdomains. Note that the matching
    # is done only on the domain itself — we consider HTTP and HTTPS to be the
    # same page for the purpose of crawling (TODO: make this a togglable option)
    def in_scope?(path)
      uri = URI path
      if @accept_subdomains
        # Need to add a '.' to the scope so that foobar.example.com
        # isn't considered a subdomain of bar.example.com
        uri.host == @scope or uri.host.end_with?('.' + @scope)
      else
        uri.host == @scope
      end
    end
  end
end