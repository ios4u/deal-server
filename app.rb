require 'sinatra'
require 'sidekiq'
require 'twilio-ruby'
require 'json'
require './sms_sender'

get '/' do 
  'Hello World'
end

get '/deals' do 
  deals_json = IO.read(File.expand_path("../deals.json", __FILE__))
  deals = JSON.parse(deals_json, symbolize_names: true)
  # Simple O(nm) filtering of JSON content for demo purposes
  filtered_deals = deals
  if request.params["minor"]
    minor_list = request.params["minor"].split(',')
    filtered_deals = []
    deals.each do |deal|
      minor_list.each do | minor |
        if deal[:minor].to_i == minor.to_i
          filtered_deals << deal
          minor_list = minor_list - minor
          break
        end
      end
    end
  end
  [200, {"Content-Type" => "application/json"}, filtered_deals.to_json]
end

get '/testapp' do 
  content_type 'text/xml'
  "<Response><Say>Hello! Help is on its way, please keep tight!</Say></Response>"
end

get '/token' do
  capability = Twilio::Util::Capability.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
  capability.allow_client_outgoing 'AP35a6b64d2a1af17b1f8efca8daa9aeaf'

  @token = capability.generate

  [200, {"Content-Type" => "application/json"}, {token: @token}.to_json]
end

post '/sms' do 
  payload = JSON.parse(request.body.read, symbolize_names: true)
  message = { 
    from: ENV['TWILIO_NUMBER'],
    to: ENV['MESSAGE_DESK_NUMBER'],
    body: payload[:message]
  }
  logger.info message
  
  sidekiq_enabled = ENV['SIDEKIQ_ENABLED'].to_i || 0
  if sidekiq_enabled == 1
    SmsSender.perform_async(message)
  else
    SmsSender.new.perform(message)
  end
  
  [202, {"Content-Type" => "application/json"}, {message: "Your message is sent."}.to_json]
end