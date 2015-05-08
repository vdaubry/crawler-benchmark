#!/usr/bin/env bash

echo "Stop sidekiq"
kill -9 $(cat tmp/pids/sidekiq.pid)