# Benchmark-crawler

Compare network requests performance of MRI VS JRuby for different number of threads

## Goal

Compare the performance of Ruby MRI VS JRuby when doing concurrent requests on a large number of websites.


## Test methodology

Crawl the first 1000 websites from [Quantcast top 1.000.000](https://www.quantcast.com/top-sites).
Measure the total time to perform a GET request against 1000 different domains. We increase the number of threads to compare how Ruby MRI and JRuby perform with different level of concurrency. 

We use [Sidekiq](https://github.com/mperham/sidekiq) to control the number of threads used to perform requests.

We use [Mechanize](https://github.com/sparklemotion/mechanize) to perform the GET request.


## Results

Total time by number of threads. Less is better.


### EC2 m3.xlarge

On [EC2 m3.xlarge](http://aws.amazon.com/ec2/instance-types/) instance (4 CPU, 15G RAM)

![Imgur](http://i.imgur.com/bSlHT8n.png)


### Mac Book Pro

On my Mac Book Pro (I7 2.2 GHz Quad core , 16G RAM) on a 80 Mbps network.

![Imgur](http://i.imgur.com/FzOpO5e.png)



