var fs = require('fs');
var request = require('request');
var async = require('async');

// Load json from file
var obj = JSON.parse(fs.readFileSync('../ressources/domains-fast.json', 'utf8'));
var urls = obj['domains'].slice(0, 1000);

process.on('uncaughtException', function (err) {
  console.log(err);
});

var start_time = Date.now();
async.forEach(urls, function (url, callback){ 
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
        callback();
      }
      else {
        console.log("GET request error : "+error);
        callback();
      }
    });
}, function(err) {
    console.log("Iterator done");
    var total_time = Date.now() - start_time;
    console.log("total time = "+total_time/1000.0+" seconds");
});