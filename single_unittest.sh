#!/bin/bash

# Check if the required argument is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <file name>"
  exit 1
fi

# Capture the timestamp argument
filename="$1"

# Invoke the truffle migrate command

test_command="truffle test $filename --compile-none --migrate-none"
echo "$test_command"
