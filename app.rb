require 'bundler/setup'

require 'dotenv/load'
require 'sinatra'
require 'oauth2'
require 'sinatra/reloader' if development?

enable :sessions

get '/' do
  if authenticated?
    token = token_from_session
    body = token.get(ENV["TEST_URL"]).body
    @response_json = JSON.pretty_generate(JSON.parse(body))
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

  def token_from_session
    return nil unless session['token']

    OAuth2::AccessToken.from_hash(client, session['token'])
  end

  def client
    OAuth2::Client.new(ENV["CLIENT_ID"], ENV["CLIENT_SECRET"], site: ENV["OAUTH_SITE"])
  end
end
