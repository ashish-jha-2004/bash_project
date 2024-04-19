#!/usr/bin/env bash

# Author :- Ashish Kumar

# Function to generate a random 16-digit number
generate_random_16_digit_number() {
    # Generate 16 random digits and concatenate them
    number=""
    for i in {1..16}; do
        digit=$(( RANDOM % 10 ))
        number="${number}${digit}"
    done
    echo "$number"
}

# Function to commit changes
function commit {
    # Copy the path from the hidden file from .flag
    pa=$(cat .flag)
    # Copy the path of the present working directory
    cuwd=$(pwd)
    # Get the current commit count
    cnt=$(cat .cnt)
    # Change directory to the repository path
    cd "$pa"
    # Generate a random 16-digit number and append it to .git_log
    generate_random_16_digit_number >> .git_log
    # Append the commit message to .git_log
    echo "$1" >> .git_log
    # Create a directory for the commit
    mkdir "commit_${cnt}"
    # Change back to the original directory
    cd "$cuwd"
    # Copy all files from the current directory to the commit directory
    cp -r ./* "${pa}/commit_${cnt}"
    # Increment the commit count
    ((cnt = cnt + 1))
    # Update the commit count in .cnt
    echo "$cnt" > .cnt
}
