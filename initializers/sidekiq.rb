
redis_url = if ENV['REDIS_PASSWORD'].nil? 
              "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/15"
            else
              "redis://:#{ENV['REDIS_PASSWORD']}@#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/15"
            end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end