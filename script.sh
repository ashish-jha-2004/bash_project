#!/bin/bash

# Extract exam columns (excluding Total)
exams=$(head -n1 main.csv | sed 's/Roll_Number,Name,//;s/Total//;s/,,/,/g')

# Create header for stats.csv
echo "Exam,Mean,Median,Standard Deviation" > stats.csv

# Function to calculate mean for a column, interpreting 'a' as 0
function calculate_mean {
    col_num=$1
    awk -F, -v col="$col_num" 'NR>1 {sum += ($col == "a" ? 0 : $col)} END {print sum/(NR - 1)}' main.csv
}

# Function to calculate median for a column, interpreting 'a' as 0
function calculate_median {
    col_num=$1
    awk -F, -v col="$col_num" '
    NR>1 {
        if ($col != "a") {
            a[n++] = $col;
        } else {
            a[n++] = 0;
        }
    }
    END {
        # Sort the array
        for (i = 1; i < n; i++) {
            for (j = i + 1; j <= n; j++) {
                if (a[i] > a[j]) {
                    temp = a[i];
                    a[i] = a[j];
                    a[j] = temp;
                }
            }
        }

        mid = int(n / 2);
        if (n % 2) {
            print a[mid];
        } else {
            print (a[mid] + a[mid + 1]) / 2;
        }
    }' main.csv
}

# Function to calculate standard deviation for a column, interpreting 'a' as 0
function calculate_std_dev {
    col_num=$1
    mean=$(calculate_mean $col_num)
    awk -F, -v col="$col_num" -v mean="$mean" '
    NR>1 {
        if ($col != "a") {
            sum += ($col - mean)^2
            count++
        } else {
            sum += (0 - mean)^2
            count++
        }
    }
    END {print sqrt(sum/count)}' main.csv
}



# Process each exam column
IFS=',' read -ra columns <<< "$exams"
for exam in "${columns[@]}"; do
    col_num=$(awk -F, -v exam="$exam" 'NR==1 {for (i=3; i<=NF; i++) {if ($i == exam) {print i; exit}}}' main.csv)
    mean=$(calculate_mean $col_num)
    median=$(calculate_median $col_num)
    std_dev=$(calculate_std_dev $col_num)
    echo "$exam,$mean,$median,$std_dev" >> stats.csv
done

