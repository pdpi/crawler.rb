#!/usr/bin/env bash

xcode-select --install
brew install rbenv ruby-build
rbenv install 2.2.2
rbenv local 2.2.2
gem install bundler
rbenv rehash
bundle install
