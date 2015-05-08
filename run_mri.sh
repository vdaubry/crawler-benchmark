#!/usr/bin/env bash

./start_sidekiq.sh $1

nb_domains=${2-1000}
echo "Start crawler"
ruby bin/benchmark $nb_domains

./stop_sidekiq.sh