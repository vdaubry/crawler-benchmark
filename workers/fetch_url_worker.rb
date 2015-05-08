class FetchUrlWorker
  include Sidekiq::Worker
   sidekiq_options :queue => :crawler, :retry => false, :backtrace => true
  
  def perform(url)
    puts "Get #{url}"
    begin
      agent = Mechanize.new
      agent.open_timeout=5
      agent.get(url)
    rescue StandardError => e
      puts "Couldn't get #{url} : #{e}"
    end
  end
end