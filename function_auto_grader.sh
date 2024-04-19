#!/usr/bin/env bash

# Author :- Ashish Kumar

# combine function for main.csv
function combine {
    echo "Roll_Number,Name" > main.csv

    # Finding all the unique student and copying it to main.csv
    for file in *.csv; do
        while IFS=, read -r roll_number name mark; do

            # checking if the following roll_number already exist or not in main.csv
            # if not exist then appen the same 
            if ! grep -q "^$roll_number,$name$" main.csv; then
                echo "$roll_number,$name" >> main.csv
            fi
        done < <(awk 'NR > 1'  $file)
        # <(awk 'NR > 1'  $file) is giving input all the lines except the first one
    done

    #Iterating over every csv file and find that roll_number marks
    for files in *.csv; do

        # If files is main.csv then skip
        if [ "$files" == "main.csv" ]; then
            continue
        fi

        # extacting the file from file.csv
        base=$(basename "$files" .csv)

        # adding base to the first line of main file
        sed -i "1 s/$/,$base/" main.csv

        # Iteraring over all the roll_number in the main.csv file
        while IFS=, read -r roll_number name; do

            # If the roll_number exist in the files or not
            # If present then append the marks
            if grep -q "^$roll_number" $files; then
                lin=$(grep -E "^$roll_number.*$" $files | cut -d "," -f3)
                old_pattern=$(grep -E "^$roll_number.*$" main.csv)
                sed -i "s/$old_pattern/$old_pattern,$lin/g" main.csv
            # If not present then append 'a'
            else
                old_pattern=$(grep -E "^$roll_number.*$" main.csv)
                sed -i "s/$old_pattern/$old_pattern,a/g" main.csv
            fi
        done < <(awk 'NR > 1'  main.csv)
    done

}

# upload function for main.csv
function upload {
    # copy file from given directory to script directory
    cp "$1" ./

}

# total function for main.csv
function total {

    # If statement is to avoid multiple totals in the main.csv
    if ! grep -q "^Roll_Number,Name.*,Total$" main.csv; then
        file="main.csv"

        # Adding a new column total to the file
        sed -i '1s/$/,Total/' "$file"

        # making a temporary file
        temp_file=$(mktemp)

        # Iterate from column 3 to end and find the total and taking "a" as 0.
        awk -F',' 'NR==1 {print; next} {
            total=0;
            for(i=3; i<=NF; i++) {
                total += ($i == "a") ? 0 : $i;
            }
            $0 = $0 "," total;
            print $0;
        }' OFS=',' "$file" > "$temp_file" && mv "$temp_file" "$file"
        # now changing name of temp_file to main.csv
    fi

}

# update function for main.csv 
function update {

    # taking Input fromm the TA
    read -p "Type the roll number : " roll_number
    read -p "Type exam name : " exam_name
    read -p "Type the new marks : " marks

    # Chnaging the marks in the exam_name.csv
    old_pattern=$(grep -E "^$roll_number.*$" $exam_name.csv)
    axis=$(grep -E "^$roll_number.*$" $exam_name.csv | cut -d "," -f2)

    sed -i "s/$old_pattern/$roll_number,$axis,$marks/g" "$exam_name.csv"

    # Changing the main.csv accordingly
    if [ -e main.csv ]; then
        if grep -q "^Roll_Number,Name.*,Total$" main.csv; then
            combine
            total
        else 
            combine
        fi
    else 
        combine
    fi

}

########################################################################################################################################################################################

#customization

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
