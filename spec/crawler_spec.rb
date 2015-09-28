require 'crawler'
require 'faraday'
require 'uri'

RSpec.describe Crawler::Crawler do
  before :all do
    @body = %{
      <!DOCTYPE html>
      <html>
        <head>
          <title>This is an example</title>
          <script>console.log('yikes');</script>
          <script src='www.example.com/foo.js'></script>
          <script src='/bar.js'>foo</script>
        </head>
        <body>
          <p>This is some text in here that has an embedded
            <a href='path/to/relative/page.html'>link</a> in the middle of it.
          </p>
          <a href='//protoc.ol/relative/page.html'>World</a>
        </body>
      </html>
    }
    @headers = {
      'content-type' => 'text/html'
    }

   @self_referencing = %{
      <!DOCTYPE html>
      <html>
        <head>
          <title>This is an example</title>
        </head>
        <body>
          <p>
            This is some text in here that has a
            <a href='http://www.example.com/'>self-referential link</a>
            in the middle of it.
          </p>
        </body>
      </html>
    }

  end
  context 'when dealing with failures' do
    it 'retries the prescribed number of times' do
      path = 'http://www.example.com/'
      resp = double 'resp'
      allow(resp).to receive(:status).and_return(404)
      allow(resp).to receive(:headers).and_return(@headers)
      # allow(resp).to receive(:body).and_return(@body)
      config = {
        'max_retries' => 10,
        'accept_subdomains' => false,
        'interval' => 0
      }
      crawler = Crawler::Crawler.new path, config
      expect_any_instance_of(Crawler::Page).to receive(:fetch).exactly(10).times.with(URI path).and_return(resp)
      crawler.crawl()
    end
  end

  context 'when crawling' do
    it "doesn't chase links that have already been visited" do
      path = 'http://www.example.com/'
      resp = double 'resp'
      allow(resp).to receive(:status).and_return(200)
      allow(resp).to receive(:headers).and_return(@headers)
      allow(resp).to receive(:body).and_return(@self_referencing)
      config = {
        'max_retries' => 10,
        'accept_subdomains' => false,
        'interval' => 0
      }
      crawler = Crawler::Crawler.new path, config
      expect_any_instance_of(Crawler::Page).to receive(:fetch).exactly(:once).with(URI path).and_return(resp)
      crawler.crawl()
    end
  end
end