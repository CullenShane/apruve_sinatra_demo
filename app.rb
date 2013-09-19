require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'coffee-script'
require 'net/http'
require File.join(File.dirname(__FILE__), '.', 'apruve.rb')

api_key = ''
merchant_id = ''

get '/' do
  erb :index
end
