# Introduction

This is the server side for the sample iOS application that demonstrates using iBeacons and Twilio APIs. This provides API support to download a sample list of deals, sending SMS message using Twilio API and serving capability tokens for the Twilio iOS client.

Please read the README file for the iOS application [Dealcast](https://github.com/keremk/dealcast) to learn more about the scenario and the application.

# Installation

This server app can be configured with or without using the Sidekiq for background tasks. For real production tasks, external API connections to Twilio for sending SMS should probably be done using Sidekiq, but if you want to simply host this at Heroku for free, you can disable the use of Sidekiq which requires a worker and Redis server.

For configuration, create a .env file and store the following keys:

    TWILIO_SID=YOUR_SID
    TWILIO_TOKEN=YOUR_TOKEN
    TWILIO_NUMBER=+14555551212 \\ For testing, your trial Twilio number
    MESSAGE_DESK_NUMBER=+14155551212 \\ For testing, the approved Twilio number
    SIDEKIQ_ENABLED=0 \\ Set this to 1 to enable Sidekiq in app.rb

The .env file is in .gitignore, so it is not in Git.

To configure Sidekiq, you need to add the following line to your Procfile and make sure there is a local Redis server running:

    worker: bundle exec sidekiq -r ./app.rb

Then run to install the gems:

    bundle install --path vendor/bundle

Now you are ready to run the server:

    foreman start

Note that, the Twilio App (served through /testapp endpoint), will not work from localhost, as Twilio servers need to reach out to it. So you need to run the server in an externally reachable server. (I am using Heroku)

To configure the testapp, you need to go to your [Twilio Account](https://www.twilio.com/user/account/apps) and add the testapp end point. See the [Twilio quick start guides on TwiML apps](https://www.twilio.com/docs/quickstart/ruby/twiml).

