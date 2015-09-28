require 'page'
require 'faraday'
require 'uri'

RSpec.describe Crawler::Page do
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

   @all_hashes = %{
      <!DOCTYPE html>
      <html>
        <head>
          <title>This is an example</title>
        </head>
        <body>
          <p>This is some text in here that has an embedded
            <a href='#foo'>hash-based link</a> in the middle of it.
          </p>
        </body>
      </html>
    }

  end

  context 'when searching for scripts' do
    it "detects only script tags with 'src' attributes" do
      path = 'http://www.example.com/'
      resp = double 'resp'
      allow(resp).to receive(:status).and_return(200)
      allow(resp).to receive(:headers).and_return(@headers)
      allow(resp).to receive(:body).and_return(@body)
      page = Crawler::Page.new path
      expect(page).to receive(:fetch).with(URI path).and_return(resp)
      page.visit()
      expect(page.scripts.length).to eq(2)
    end
  end

  context 'when searching for links' do
    it 'finds all links' do
      path = 'http://www.example.com/'
      resp = double 'resp'
      allow(resp).to receive(:status).and_return(200)
      allow(resp).to receive(:headers).and_return(@headers)
      allow(resp).to receive(:body).and_return(@body)
      page = Crawler::Page.new path
      expect(page).to receive(:fetch).with(URI path).and_return(resp)
      page.visit()
      expect(page.links.length).to eq(2)
    end

    it 'ignores hash links' do
      path = 'http://www.example.com/'
      resp = double 'resp'
      allow(resp).to receive(:status).and_return(200)
      allow(resp).to receive(:headers).and_return(@headers)
      allow(resp).to receive(:body).and_return(@all_hashes)
      page = Crawler::Page.new path
      expect(page).to receive(:fetch).with(URI path).and_return(resp)
      page.visit()
      expect(page.links.length).to eq(0)
    end
  end
end