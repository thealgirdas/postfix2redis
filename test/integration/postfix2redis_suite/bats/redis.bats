#!/usr/bin/env bats

@test "redis-cli is installed and in the path" {
  which redis-cli
}

@test "check redis service" {
  redis-cli -h 127.0.0.1 -p 6379 ping
}
