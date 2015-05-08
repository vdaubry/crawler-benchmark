$:.unshift File.dirname(__FILE__)
require 'dotenv'
require 'mechanize'
require 'sidekiq'
require 'sidekiq/api'

Dotenv.load

#Initializers
require "initializers/redis"
require "initializers/sidekiq"
#Models
require "models/crawler"
#Workers
require "workers/fetch_url_worker"