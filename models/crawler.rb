class Crawler
  def initialize(website_number: 1000)
    Sidekiq::Queue.new("crawler").clear
    @website_number = website_number.to_i
  end
  
  def jobs_count
    Sidekiq::Queue.new("crawler").size+Sidekiq::ProcessSet.new("crawler").size
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
      puts "Loading urls from JSON"
      file = File.open("#{File.expand_path(File.dirname(__FILE__))}/../ressources/domains-fast.json")
      urls = JSON.parse(file.read)["domains"][0..5000]
      urls.each do |url|
        FetchUrlWorker.perform_async(url)
      end

      loop do
        break if jobs_count==0
      end
    end
  end
end