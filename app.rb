require 'bundler/setup'

require 'dotenv/load'
require 'sinatra'
require 'rack-flash'
require 'erubi'
require 'oauth2'

require 'json'

require 'sinatra/reloader' if development?

set :erb, escape: true
enable :sessions
use Rack::Flash

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
  if params[:error]
    flash[:error] = params[:error_description]
  else
    token = client.auth_code.get_token(params[:code], redirect_uri: url('/auth/callback'))
    session['token'] = token.to_hash
  end

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
  return unless session['token']

  token = OAuth2::AccessToken.from_hash(client, session['token'])

  begin
    response = token.get(ENV["TEST_RESOURCE"])
  rescue OAuth2::Error
    session.destroy
    return
  end

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
