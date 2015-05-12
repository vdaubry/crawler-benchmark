#!/usr/bin/env ruby
require 'net/http'
require 'eventmachine'
require 'em-http-request'
require 'json'
require 'benchmark'

JSON_URL = "https://s3.amazonaws.com/vda-public-bucket/domains.json"

class MeasureDomain
  def initialize(urls:)
    @urls = urls
    @response_count = 0
  end
  
  def get_url(url:)
    puts "GET #{url}"
    page = EventMachine::HttpRequest.new(url).get
    page.errback { 
      p "Couldn't get #{url}" 
      @response_count += 1
    }
    page.callback {
      @response_count += 1
      puts "Got response from #{url} : #{page.response.size} bytes" 
    }
  end
  
  def start
    EM.run {
      n=0
      EM.error_handler{ |e|
        puts "Error raised during event loop: #{e.message}"
        EM.stop
      }
      
      EM::PeriodicTimer.new(0.01) do
        if n < @urls.size
          get_url(url: @urls[n])
          n+=1
        end
        
        EM.stop if @response_count >= @urls.count
      end
    }
  end
end

puts "Loading urls from JSON"
file = File.open("#{File.expand_path(File.dirname(__FILE__))}/../ressources/domains.json")
urls = JSON.parse(file.read)["domains"][0..1000]

start_time = Time.now.to_f
MeasureDomain.new(urls: urls).start
total_time  = Time.now.to_f - start_time
puts "Benchmark finished : called #{urls.count} urls in #{total_time} seconds"