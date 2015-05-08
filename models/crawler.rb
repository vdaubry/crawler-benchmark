class Crawler
  def initialize(website_number: 1000)
    Sidekiq::Queue.new("crawler").clear
    @website_number = website_number.to_i
  end
  
  def jobs_count
    Sidekiq::Queue.new("crawler").size
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
      f = File.open("seed/top-websites.txt", 'r')
      f.readlines[0..@website_number].each do |domain|
        url = "http://#{domain.gsub("\r\n", "")}"
        FetchUrlWorker.perform_async(url)
      end

      loop do
        break if jobs_count==0
      end
    end
  end
end