#!/usr/bin/env bash

concurrency=${1-20}
echo "Starting sidekiq with concurrency = $concurrency"
bundle exec sidekiq -C config/sidekiq.yml -c $concurrency -r ./crawler_benchmark.rb
