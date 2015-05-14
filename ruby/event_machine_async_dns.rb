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
    @success_count = 0
    @failure_count = 0
    #@resolver = RubyDNS::Resolver.new([[:udp, "52.5.37.108", 53], [:tcp, "52.5.37.108", 53]], {:timeout => 1})
    @resolver = RubyDNS::Resolver.new(RubyDNS::System::nameservers, {:timeout => 1})
  end
  
  def get_url(url:)
    @resolver.query(URI.parse(url).host) do |response|
      if response.class != Resolv::DNS::Message || response.answer.empty?
        p "Couldn't resolve hostname for #{url}" 
        @failure_count += 1
      else
        if response.answer[0][2].class == Resolv::DNS::Resource::IN::CNAME
          get_url(url: "http://#{response.answer[0][2].name.to_s}")
        else
          ip = response.answer[0][2].address.to_s
          host = response.answer[0][0].to_s
          
          domain = Addressable::URI.parse(url)
          domain.host = ip
          
          puts "get #{ip}, for #{url}"
          http = EventMachine::HttpRequest.new(domain, :connect_timeout => 5, :inactivity_timeout => 5, :keepalive => false).get(:head =>{'host' => host}, :redirects => 3)
          http.errback { 
            p "Couldn't get #{url} : #{http.error}/#{http.response}"
            @failure_count += 1
          }
          start = Time.now.to_f
          http.callback {
            @success_count += 1
            puts "Got response from #{url} : #{http.response.size} bytes in #{Time.now.to_f - start}"
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
      
      EM::PeriodicTimer.new(0.005) do
        if n < @urls.size
          url = @urls[n]
          puts "GET #{url} , #{n}"
          get_url(url: url)
          n+=1
        end
        
        #puts "@response_count = #{@response_count}" if (@urls.count - @response_count < 100)
        EM.stop if (@success_count+@failure_count) >= @urls.count
      end
    }
  end
end

puts "Loading urls from JSON"
file = File.open("#{File.expand_path(File.dirname(__FILE__))}/../ressources/domains-fast.json")
urls = JSON.parse(file.read)["domains"][1000..5000]

start_time = Time.now.to_f
MeasureDomain.new(urls: urls).start
total_time  = Time.now.to_f - start_time
puts "Benchmark finished : called #{urls.count} urls in #{total_time} seconds"