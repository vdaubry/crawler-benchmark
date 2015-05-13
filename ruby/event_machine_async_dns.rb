#!/usr/bin/env ruby
require 'eventmachine'
require 'em-http-request'
require 'rubydns'
require 'rubydns/system'
require 'json'
require 'byebug'

class MeasureDomain
  def initialize(urls:)
    @urls = urls
    @response_count = 0
    @resolver = RubyDNS::Resolver.new(RubyDNS::System::nameservers, {:timeout => 1})
  end
  
  def get_url(url:)
    puts "GET #{url}"
    
    @resolver.query(URI.parse(url).host) do |response|
      return if response.class != Resolv::DNS::Message
      
      if response.answer.empty?
        p "Couldn't resolve hostname for #{url}" 
        @response_count += 1
      else
        if response.answer[0][2].class == Resolv::DNS::Resource::IN::CNAME
          get_url(url: "http://#{response.answer[0][2].name.to_s}")
        else
          ip = response.answer[0][2].address.to_s
          host = response.answer[0][0].to_s
          
          domain = Addressable::URI.parse(url)
          domain.host = ip
          
          puts "get #{ip}, for #{url}"
          page = EventMachine::HttpRequest.new(domain, :connect_timeout => 15, :inactivity_timeout => 10).get(:head =>{'host' => host}, :redirects => 3)
          page.errback { 
            p "Couldn't get #{url}" 
            @response_count += 1
          }
          page.callback {
            @response_count += 1
            puts "Got response from #{url} : #{page.response.size} bytes"
          }
        end
      end
    end
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
file = File.open("#{File.expand_path(File.dirname(__FILE__))}/../ressources/domains-fast.json")
urls = JSON.parse(file.read)["domains"][0..20000]

start_time = Time.now.to_f
MeasureDomain.new(urls: urls).start
total_time  = Time.now.to_f - start_time
puts "Benchmark finished : called #{urls.count} urls in #{total_time} seconds"