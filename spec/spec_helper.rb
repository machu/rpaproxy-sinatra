# coding: utf-8
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'rack/test'
require 'webmock/rspec'

ENV['TWITTER_KEY'] = ENV["TWITTER_SECRET"] = "dummy"

require 'rpaproxy'

set :environment, :test

RSpec.configure do |c|
  c.include Rack::Test::Methods
end
