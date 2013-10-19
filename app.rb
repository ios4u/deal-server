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
  # Simple linear filtering of JSON content for demo purposes
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
  [200, ""]
end

get '/token' do
  # set up
  capability = Twilio::Util::Capability.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']

  # allow outgoing calls to an application
  capability.allow_client_outgoing 'APabe7650f654fc34655fc81ae71caa3ff'

  # allow incoming calls to 'monkey'
  capability.allow_client_incoming 'inquiry'

  # generate the token string
  @token = capability.generate
end

post '/send_sms' do 
  payload = JSON.parse(request.body.read, symbolize_names: true)
  message = { 
    from: ENV['TWILIO_NUMBER'],
    to: payload[:to],
    body: payload[:message]
  }
  logger.info message
  
  SmsSender.perform_async(message)
  [202, ["Your message is sent."]]
end