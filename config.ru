require 'dotenv'
require './app'

Dotenv.load
run Sinatra::Application

