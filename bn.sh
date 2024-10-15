#!/bin/bash

# Function to display usage information when arguments are incorrect
usage() {
    echo "Usage: bn <year> <gender f|F|m|M|b|B>" >&2
}

# Function to display help information, including version and argument details
help() {
    echo "Baby Names Utility - Version 1.0.0"
    echo "Usage: bn <year> <gender f|F|m|M|b|B>"
    echo "Arguments:"
    echo "  year: A four-digit integer year from 1880 onwards."
    echo "  gender: f|F for female, m|M for male, b|B for both."
}

# Check if the number of arguments is exactly 2, otherwise call usage function and exit
if [ "$#" -ne 2 ]; 
then
    usage
    exit 1
fi

# Assign command-line arguments to variables for year and gender
year="$1"
gender="$2"

# Regular expressions for validating year and gender
year_regex='^[0-9]{4}$'         # Ensures year is a four-digit number
gender_regex='^[fFmMbB]$'       # Ensures gender is one of f, F, m, M, b, or B

# Validate year format using regex; if invalid, print an error and exit
if ! [[ "$year" =~ $year_regex ]]; 
then
    echo "Invalid year format. Please enter a four-digit year." >&2
    usage
    exit 2
fi

# Validate gender format using regex; if invalid, print an error and exit
if ! [[ "$gender" =~ $gender_regex ]]; 
then
    echo "Invalid gender format. Accepted values are f, F, m, M, b, B." >&2
    usage
    exit 2
fi

# Check if the data file for the given year exists; if not, print an error and exit
file="us_baby_names/yob${year}.txt"
if [ ! -f "$file" ]; 
then
    echo "No data for ${year}" >&2
    exit 4
fi

# Function to determine the full gender description based on input
setFullGender() {
    if [[ $GENDER =~ ^[mM]$ ]]; 
    then
        FULLGENDER="male"
    elif [[ $GENDER =~ ^[fF]$ ]]; 
    then
        FULLGENDER="female"
    fi
}

# Function to find and print the rank of a specific name for a given year and gender
rankNames() {
    local FOUNDNAME=$1             # The name to search for
    local GENDER=$2                # Gender for the search (M or F)
    local YEAR=$3                  # Year for the search
    local FILE="us_baby_names/yob${YEAR}.txt"

    # Set full gender description for the output message
    setFullGender "$GENDER"

    # Calculate total number of names for the given gender in the file
    TOTALNAMES=$(cat "$FILE" | grep -i ",$GENDER," | wc -l)
    # Find the line number (rank) for the name using grep with case-insensitive match
    NAMERANKING=$(cat "$FILE" | grep -i ",$GENDER," | grep -n -i "^$FOUNDNAME," | grep -o -P "^[0-9]+")

    # Check if the name was found in the file
    if [ -n "$NAMERANKING" ]; 
    then
        echo "${YEAR}: $FOUNDNAME ranked $NAMERANKING out of $TOTALNAMES $FULLGENDER names."
    else
        echo "${YEAR}: $FOUNDNAME not found among $FULLGENDER names."
    fi
}

# Main function to process names from a single line of standard input based on specified gender
main() {
    while true; 
    do
        # Prompt the user for a line of names
        read -r line
        # Split the line into individual names using a loop
        for name in $line; 
        do
            # Validate that the name contains only alphabetical characters
            if [[ "$name" =~ ^[a-zA-Z]+$ ]]; 
            then
                if [[ $gender =~ ^[bB]$ ]]; 
                then
                    # If gender is both, check for both male and female ranks
                    rankNames "$name" "M" "$year"  # Check for male rank
                    rankNames "$name" "F" "$year"  # Check for female rank
                else
                    # For a single gender, only process that gender
                    rankNames "$name" "$gender" "$year"
                fi
            else
                echo "Badly formatted name: $name" >&2
                exit 3
            fi
        done
    done
}

# Check if the first argument is --help; if so, display help information and exit
if [ "$1" == "--help" ]; 
then
    help
    exit 0
fi

# Call the main function to process names if validations pass
main
