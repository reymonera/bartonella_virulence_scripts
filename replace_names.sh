#!/bin/bash

# Get the directory of the script
script_dir=$(dirname "$0")
echo "Script directory is: $script_dir"

# Define a default regex
regex='\b(\w{6})\b'

# Parse command line options
while getopts r: flag
do
    case "${flag}" in
        r) regex=${OPTARG};;
    esac
done

# Shift to remove the parsed options
shift $((OPTIND -1))

# Bash script to pass all files as separate arguments
echo "Processing files: $@"
python3 $script_dir/process_names.py "$@" "$regex"

# Usage: -r 'your_regex_here' file1 file2 file3