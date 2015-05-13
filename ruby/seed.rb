require 'redis'
require 'json'

$redis = Redis.new(host: '104.239.165.215', port: 6379, password: ENV['REDIS_PASSWORD'])
urls = $redis.zrangebyscore("bc:domains:perf", 0, 1)
urls = urls.map {|url| "http://#{url}"}
File.open("../ressources/domains-fast.json", 'w') do |f|
  h = {"domains": urls}
  f.puts h.to_json
end