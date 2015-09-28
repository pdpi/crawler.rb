# Pedro's simple web crawler

This is just a simple demo web crawler.

## Prerequisites

 - Ruby. The crawler was developed against 2.2.2, but should work on older versions.
 - A build environment that supports building Nokogiri

## Setup

Provided you have all prerequisites available, you can setup the application by running
the following:

```
gem install bundler
bundle install
```

Getting Nokogiri to install can be somewhat painful. If you're on OS X and have
Homebrew installed, the `quick-start.sh` script should sort that process out
(though it will install a few things along the way, such as the XCode commandline
tools)

## Usage

You can run the crawler with `./crawler.rb <url>`.

## Configuration

You can edit `config/config.yaml` to tune some of the crawling behaviours.

## Demo

If you want a demo page to try the crawler on, just run this from the project home:

    ruby -run -ehttpd demo/ -p8000

You can then point the crawler at your localhost:

    ./crawler.rb http://localhost:8000