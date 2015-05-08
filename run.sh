#!/usr/bin/env bash

concurrency=${1-20}
echo "Starting sidekiq with concurrency = $concurrency"
bundle exec sidekiq -C config/sidekiq.yml -c $concurrency -r ./crawler_benchmark.rb -d -L tmp/log/sidekiq.log

nb_domains=${2-1000}
echo "Start crawler"
bin/benchmark $nb_domains

echo "Stop sidekiq"
kill -9 $(cat tmp/pids/sidekiq.pid)