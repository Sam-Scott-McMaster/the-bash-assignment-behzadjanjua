#!/bin/bash

usage() {
	echo "Usage: bn <year> <gender f|F|m|M|b|B>" >&2
}

help() {
	echo "Baby Names Utility - Version 1.0.0"
    	echo "Usage: bn <year> <gender f|F|m|M|b|B>"
    	echo "Arguments:"
    	echo "  year: A four-digit integer year from 1880 onwards."
    	echo "  gender: f|F for female, m|M for male, b|B for both."
}

# Error handling for incorrect number of arguments
if [ "$#" -ne 2 ]; 
then
    usage #call function
    exit 1
fi

# Extract and validate arguments
year="$1"
gender="$2"

# Regex to find 
year_regex='^[0-9]{4}$'
gender_regex='^[fFmMbB]$'

# Validate year format with regex
if ! [[ "$year" =~ $year_regex ]]; 
then
    echo "Invalid year format. Please enter a four-digit year." >&2
    usage
    exit 2
fi

# Validate gender format with regex
if ! [[ "$gender" =~ $gender_regex ]]; then
    echo "Invalid gender format. Accepted values are f, F, m, M, b, B." >&2
    usage
    exit 2
fi

