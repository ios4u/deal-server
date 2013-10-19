require 'twilio-ruby'

class SmsSender
  include Sidekiq::Worker
  sidekiq_options :retry => 5, :backtrace => 5

  def perform(message)
    client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
    client.account.messages.create(
      :from => message["from"],
      :to => message["to"],
      :body => message["body"]
    )
  end
end