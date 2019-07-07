require 'bundler/setup'

require 'dotenv/load'
require 'sinatra'
require 'oauth2'

get '/' do
  "Hello, world!"
end
