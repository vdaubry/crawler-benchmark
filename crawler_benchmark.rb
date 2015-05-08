$:.unshift File.dirname(__FILE__)
require 'dotenv'
require 'mechanize'
require 'sidekiq'
require 'sidekiq/api'

#Initializers
require "initializers/redis"
#Models
require "models/crawler"
#Workers
require "workers/fetch_url_worker"