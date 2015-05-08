#!/usr/bin/env bash

nb_domains=${1-1000}
echo "Start crawler"
jruby bin/benchmark $nb_domains

./stop_sidekiq.sh