require 'sinatra'
require 'nokogiri'
# require 'slim'
require 'faraday'
require 'json'
require 'ostruct'
require "sinatra/reloader" if development?
require "sinatra/content_for"

Settings = OpenStruct.new({
  site_name: 'Mailgun Viewer'
})

# Needed for the @messages json serialization in index.slim
set :slim, disable_escape: true


post '/' do
  api_key = params[:api_key]
  domain = params[:domain]
  conn = Faraday.new(url: "https://api.mailgun.net/v3/#{domain}/")
  conn.basic_auth('api', api_key)
  response = conn.get "events"
  unless response.status==200
    return "Could not fetch. Mailgun returned #{response.status}: #{response.body}"
  end
  json = JSON.parse(response.body)
  @messages = json['items'].map do |i|
    i.dig('storage', 'url')
  end
  @messages = @messages.compact.uniq
  @messages = @messages.map do |url|
    JSON.parse(conn.get(url).body)
    # message
  end
  slim :'messages/index'
end

get '/' do
  slim :'messages/new'
end