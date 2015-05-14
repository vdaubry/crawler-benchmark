require 'sidekiq'
require 'sidekiq/api'
require 'json'
require_relative 'fetch_url_worker'
require_relative 'redis_init'

class Crawler
  def initialize(website_number:)
    Sidekiq::Queue.new("crawler").clear
    @website_number = (website_number || 5000).to_i
  end
  
  def jobs_count
    Sidekiq::Queue.new("crawler").size+Sidekiq::ProcessSet.new("crawler").size-1
  end
  
  def measure
    start_time = Time.now
    puts "Crawling #{@website_number} domains"
    
    yield
    
    end_time = Time.now
    puts "Done"
    puts "total time = #{end_time - start_time}"
  end
    
  def start
    measure do
      file = File.open("#{File.expand_path(File.dirname(__FILE__))}/../../ressources/domains-fast.json")
      urls = JSON.parse(file.read)["domains"][0..@website_number]
      puts "Loading #{urls.count} urls from JSON"
      urls.each do |url|
        FetchUrlWorker.perform_async(url)
      end

      loop do
        break if jobs_count==0
      end
    end
  end
end

Crawler.new(website_number: ARGV[0]).start