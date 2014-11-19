#!/usr/bin/env bats

@test "master.cf is correct" {
  grep "redis_filter" /etc/postfix/master.cf
}

@test "postfix.sh is in place and executable" {
  [ -x /etc/postfix/postfix2redis.sh ]
}
