require 'bundler/setup'

require 'dotenv/load'

require 'sinatra'
require 'oauth2'

require 'sinatra/reloader' if development?

get '/' do
  erb :index
end
