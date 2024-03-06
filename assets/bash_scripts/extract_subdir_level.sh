#!/bin/bash

# Input comma-separated string
root_path="$1"
input_string="$2"

# Split the input string by comma
IFS=',' read -ra directories <<< "$input_string"

# Initialize an empty string to store results
result_string=""

# Iterate over each directory
for dir in "${directories[@]}"; do
  # Find subdirectories
  IFS=' ' read -ra subdirs <<< $(find "$root_path/$dir" -mindepth 1 -maxdepth 1 -type d -printf "%f ")
  
  # Prepend each subdirectory with its original value from input_string
  for subdir in ${subdirs[@]}; do
    result_string+="$dir/${subdir##*/},"
  done
done

# Remove the trailing comma, if any
result_string=${result_string%,}

echo "$result_string"

