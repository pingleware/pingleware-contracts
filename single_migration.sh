#!/bin/bash

# Check if the required argument is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <migration number>"
  exit 1
fi

# Capture the timestamp argument
number="$1"

# Invoke the truffle migrate command
truffle migrate --compile-none --f $number --to $number
