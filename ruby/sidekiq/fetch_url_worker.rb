# Start sidekiq with : sidekiq -c 40 -r ./ruby/sidekiq/fetch_url_worker.rb

require 'sidekiq'
require 'mechanize'
require 'timeout'
require 'resolv-replace'
require_relative 'redis_init'

class FetchUrlWorker
  include Sidekiq::Worker
   sidekiq_options :queue => :crawler, :retry => false, :backtrace => true
  
  def perform(url)
    puts "Get #{url}"
    begin
      agent = Mechanize.new
      agent.open_timeout=5
      agent.read_timeout=5
      Timeout::timeout(10) {agent.get(url)}
    rescue StandardError => e
      puts "Couldn't get #{url} : #{e}"
    end
  end
end