var fs = require('fs');
var request = require('request');
var redis = require("redis");

var delay = 0.1;
function pollRedis() {    
  setTimeout(function() {
    client.lpop("bc:domains:perf:node:list", function(err, url) {
      if(url) {
        getUrl(url)
        pollRedis()
      }
      else {
        client.llen("bc:domains:perf:node:list", function(err, res) {
          console.log("Redis list length = "+res);
          var total_time = Date.now() - start_time;
          console.log("total time = "+total_time/1000.0+" seconds");
        });
      }
    })
  }, delay);
}

function getUrl(url) {
  console.log("GET "+url);
  request({
      uri: url,
      method: "GET",
      timeout: 15000,
      followRedirect: true,
      maxRedirects: 10
    }, function (error, response, body) {
    
    if (!error && response.statusCode == 200) {
      console.log("Done "+url+", size = "+body.length);
    }
    else {
      console.log("GET request error : "+error);
      console.log("GET request status : "+response.statusCode);
    }
  });
}

process.on('uncaughtException', function (err) {
  console.log(err);
});


// Load json from file
console.log("Loading urls in redis")
var obj = JSON.parse(fs.readFileSync('../ressources/domains-fast.json', 'utf8'));
var urls = obj['domains'].slice(0, 1000);
client = redis.createClient(6379, '104.239.165.215', {auth_pass: process.env.REDIS_PASSWORD})

client.on("error", function (err) {
  console.log("Error " + err);
});

client.del('bc:domains:perf:node:list')
for (var index in urls) {
  var url = urls[index];
  client.lpush('bc:domains:perf:node:list', url);
}

var start_time = Date.now();
pollRedis();