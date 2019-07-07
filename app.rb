require 'bundler/setup'

require 'dotenv/load'
require 'sinatra'
require 'erubi'
require 'oauth2'

require 'json'

require 'sinatra/reloader' if development?

set :erb, escape: true
enable :sessions

get '/' do
  if authenticated?
    @output = get_test_resource
  end

  erb :index
end

get '/auth' do
  redirect client.auth_code.authorize_url(redirect_uri: url('/auth/callback'))
end

get '/auth/callback' do
  token = client.auth_code.get_token(params[:code], redirect_uri: url('/auth/callback'))
  session['token'] = token.to_hash

  redirect to('/')
end

get '/logout' do
  session.destroy

  redirect to('/')
end

helpers do
  def authenticated?
    !!session['token']
  end
end

def get_test_resource
  return nil unless session['token']

  token = OAuth2::AccessToken.from_hash(client, session['token'])
  response = token.get(ENV["TEST_RESOURCE"])

  s = "Status: #{response.status}\n"
  s += response.headers.map { |k, v| "#{k}: #{v}" }.join("\n")
  s += "\n\n"

  if response.content_type == 'application/json'
    s += JSON.pretty_generate(JSON.parse(response.body))
  else
    s += response.body
  end

  s
end

def client
  OAuth2::Client.new(ENV["CLIENT_ID"], ENV["CLIENT_SECRET"], site: ENV["AUTHORIZATION_SERVER"])
end
