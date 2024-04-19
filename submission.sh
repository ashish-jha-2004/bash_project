#!/usr/bin/env bash

# Author :- Ashish Kumar (23B1028)

###########################################################################################################################################################################

###############
# Auto Grader #
###############

# Source the function_auto_grader.sh file to include its functions
source function_auto_grader.sh

# Combine function for main.csv
if [ "$1" == "combine" ]; then
    if [ -e main.csv ]; then
        # Check if the main.csv file contains the required header
        if grep -q "^Roll_Number,Name.*,Total$" main.csv; then
            # Call combine function
            combine
            # Call total function
            total
        else 
            # Call combine function only
            combine
        fi
    else 
        # Call combine function only
        combine
    fi
fi

# Upload function for main.csv
if [ "$1" == "upload" ]; then
    # Call upload function with the second argument as the file to upload
    upload "$2"
fi

# Total function for main.csv
if [ "$1" == "total" ]; then
    # Call total function
    total
fi

# Update function for main.csv
if [ "$1" == "update" ]; then
    # Call update function
    update
fi

# Stats function for main.csv
if [ "$1" == "stats" ]; then
    # Check if main.csv file exists
    if [ ! -f "main.csv" ]; then
        echo "main.csv is not present"
        exit 1
    fi
    # Extract exam columns (excluding Total)
    exams=$(head -n1 main.csv | sed 's/Roll_Number,Name,//;s/Total//;s/,,/,/g')

    # Create header for stats.csv
    echo "Exam,Mean,Median,Standard Deviation" > stats.csv

    # Process each exam column
    IFS=',' read -ra columns <<< "$exams"
    for exam in "${columns[@]}"; do
        # Get the column number for the exam
        col_num=$(awk -F, -v exam="$exam" 'NR==1 {for (i=3; i<=NF; i++) {if ($i == exam) {print i; exit}}}' main.csv)
        # Calculate mean, median, and standard deviation for the exam column
        mean=$(calculate_mean $col_num)
        median=$(calculate_median $col_num)
        std_dev=$(calculate_std_dev $col_num)
        # Append exam statistics to stats.csv
        echo "$exam,$mean,$median,$std_dev" >> stats.csv
    done
fi


############################################################################################################################################################

##########################
# Version Control System #
##########################

# Source the function_git.sh file to include its functions
source function_git.sh

# Check if the command is git_init
if [ "$1" == "git_init" ]; then
    # Create a directory specified by the second argument
    path="$2"
    mkdir -p $path
    # Store the path in a flag file
    echo "$path" > .flag
    # Initialize commit count to 1
    echo "1" > .cnt
    # Store the current directory
    current_d=$(pwd)
    # Change directory to the specified path
    cd $path
    # Create a .git_log file to store commit information
    touch .git_log
    # Change back to the original directory
    cd $current_d
fi

# Check if the command is git_commit
if [ "$1" == "git_commit" ]; then
    # Check if git is initialized
    if [ ! -f .flag ]; then
        echo "git is not initialized"
        exit 1
    else 
        # Call the commit function with the commit message
        commit "$3"
        # Get the current commit count
        cnt=$(cat .cnt)
        # Check if there are at least 2 commits
        if [ $cnt -gt 2 ]; then
            # Get the path from the flag file
            pa=$(cat .flag)
            # Decrement the commit count
            ((cnt = cnt - 1))
            # Get the paths for the last two commits
            directory_path2="${pa}/commit_${cnt}"
            ((cnt = cnt - 1))
            directory_path1="${pa}/commit_${cnt}"
            # Check if the directories exist
            if [ ! -d "$directory_path2" ] || [ ! -d "$directory_path1" ]; then
                echo "Directories not found"
                exit 1
            fi
            # Iterate over files in directory_path2
            for file1 in "$directory_path2"/*; do
                if [ -f "$file1" ] && [ "${file1##*/}" != ".*" ]; then
                    # Check if the file exists in directory_path1
                    file2="$directory_path1/${file1##*/}"
                    if [ -e "$file2" ] && [ "${file2##*/}" != ".*" ]; then
                        # Compare the files
                        cmp -s "$file1" "$file2"
                        if [ $? -ne 0 ]; then
                            echo "${file1##*/} : Modified"
                        else
                            echo "${file1##*/} : Unmodified"
                        fi
                    fi
                fi
            done
        fi
    fi
fi

# Check if the command is git_checkout
if [ "$1" == "git_checkout" ]; then
    # Print the current directory
    echo $(pwd)
    # Get the path from the flag file
    pat=$(cat .flag)
    # Check if the commit specified by the second argument exists
    # checking how much commit exist with the same no.
    ct=$(grep -E "$2" "${pat}/.git_log" | wc -l)
    # if ct == 0 then no any such commit exists
    if [ $ct -eq 0 ]; then
        echo "no such commits exist"
        exit 1
    fi
    # if the count is greater then 1 then conflict occurs
    if [ $ct -gt 1 ]; then
        echo "conflict occurred"
        exit 1
    # otherwise do the usual stuff
    else 

        # Store the current working directory
        cw=$(pwd)
        # Change directory to the repository path
        cd $pat
        # Get the line number of the commit in the .git_log file
        line_no=$(awk -v pattern="$2" '$0 ~ pattern { print NR }' .git_log)
        # Calculate the commit number based on whether the line number is even or odd
        number=$line_no
        cd $cw
        if [ $((number % 2)) -eq 0 ]; then
            ((number = number/2))
            cp -r "${pat}/commit_${number}" ./
        else
            ((number = (number+1)/2))
            cp -r "${pat}/commit_${number}" ./
        fi
    fi
fi
