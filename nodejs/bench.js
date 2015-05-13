var fs = require('fs');
var request = require('request');

var delay = 100;
function waitForUrlComplete() {    
  setTimeout(function() {
    if(i < urls.length) {
      waitForUrlComplete();
    }
    else {
      var total_time = Date.now() - start_time;
      console.log("total time = "+total_time/1000.0+" seconds");
    }
  }, delay);
}

// Load json from file
var obj = JSON.parse(fs.readFileSync('../ressources/domains.json', 'utf8'));
var urls = obj['domains'].slice(0, 1000);

process.on('uncaughtException', function (err) {
  console.log(err);
});

var i=0;
for (var url in urls) {
  url = obj['domains'][url];
  
  console.log("GET "+url);
  request({
      uri: url,
      method: "GET",
      timeout: 15000,
      followRedirect: true,
      maxRedirects: 10
    }, function (error, response, body) {
    
    if (!error && response.statusCode == 200) {
      console.log("Done, size = "+body.length);
      i+=1;
    }
    else {
      console.log("GET request error : "+error);
      console.log("GET request status : "+response.statusCode);
      i+=1;
    }
  });
}


var start_time = Date.now();
waitForUrlComplete();