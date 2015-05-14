redis_url = if ENV['REDIS_PASSWORD'].nil? 
              "redis://127.0.0.1:6379"
            else
              "redis://:#{ENV['REDIS_PASSWORD']}@104.239.165.215:6379"
            end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end