# bin/bash
# Some example test cases are given. You should add more test cases.

# GLOBALS: tc = test case number, fails = number of failed cases
declare -i tc=0
declare -i fails=0

############################################
# Run a single test. Runs a given command 3 times
# to check the return value, stdout, and stderr
#
# GLOBALS: tc, fails
# PARAMS: $1 = command
#         $2 = expected return value
#         $3 = standard input text to send
#         $4 = expected stdout
#         $5 = expected stderr
# RETURNS: 0 = success, 1 = bad return,
#          2 = bad stdout, 3 = bad stderr
############################################
test() {
    tc=tc+1

    local COMMAND=$1
    local RETURN=$2
	local STDIN=$3
    local STDOUT=$4
    local STDERR=$5

    # CHECK RETURN VALUE
    $COMMAND <<< "$STDIN" >/dev/null 2>/dev/null
    local A_RETURN=$?

    if [[ "$A_RETURN" != "$RETURN" ]]; then
        echo "Test $tc Failed"
        echo "   $COMMAND"
        echo "   Expected Return: $RETURN"
        echo "   Actual Return: $A_RETURN"
        fails=$fails+1
        return 1
    fi

    # CHECK STDOUT
    local A_STDOUT=$($COMMAND <<< "$STDIN" 2>/dev/null)

    if [[ "$STDOUT" != "$A_STDOUT" ]]; then
        echo "Test $tc Failed"
        echo "   $COMMAND"
        echo "   Expected STDOUT: $STDOUT"
        echo "   Actual STDOUT: $A_STDOUT"
        fails=$fails+1
        return 2
    fi

    # CHECK STDERR
    local A_STDERR=$($COMMAND <<< "$STDIN" 2>&1 >/dev/null)

    if [[ "$STDERR" != "$A_STDERR" ]]; then
        echo "Test $tc Failed"
        echo "   $COMMAND"
        echo "   Expected STDERR: $STDERR"
        echo "   Actual STDERR: $A_STDERR"
        fails=$fails+1
        return 3
    fi

    # SUCCESS
    echo "Test $tc Passed"
    return 0
}

##########################################
# EXAMPLE TEST CASES
##########################################

# simple success
test './bn 2022 m' 0 'Sam' '2022: Sam ranked 658 out of 14255 male names.' ''

# multi line success
test './bn 2022 B' 0 'Sam' '2022: Sam ranked 658 out of 14255 male names.
2022: Sam ranked 6628 out of 17660 female names.' ''

# error case
test './bn 2022 F' 3 'Sam2' '' 'Badly formatted name: Sam2'

# multi line error case #2
test './bn 1111 X' 2 '' '' 'Badly formatted assigned gender: X
bn <year> <assigned gender: f|F|m|M|b|B>'

# Error Case - Incorrect Year Format
test './bn 22 m' 2 '' '' 'bn <year> <assigned gender: f|F|m|M|b|B>'

# Error Case - Incorrect Gender Code
test './bn 2022 z' 2 '' '' 'Badly formatted assigned gender: z\nbn <year> <assigned gender: f|F|m|M|b|B>'

# Error Case - Missing Data File for Year
test './bn 1500 m' 4 '' '' 'No data for 1500'

# Success Case - Name Not Found
test './bn 2022 m' 0 'NonExistentName' '2022: NonExistentName not found among male names.' ''

# Help Flag
test './bn --help' 0 '' 'bn utility v1.0.0\nUsage:\nbn <year> <assigned gender: f|F|m|M|b|B>\n...' ''

# Error Case - Non-Alphabetical Characters in Name
test './bn 2022 f' 3 'Ann@' '' 'Badly formatted name: Ann@'

# Mixed Case for Gender (both)
test './bn 2022 b' 0 'Jordan' '2022: Jordan ranked 120 out of 15000 male names.\n2022: Jordan ranked 250 out of 18000 female names.' ''

# Multiple Names as Input
test './bn 2020 f' 0 'Emily Ava Mia' '2020: Emily ranked 12 out of 18000 female names.\n2020: Ava ranked 20 out of 18000 female names.\n2020: Mia ranked 50 out of 18000 female names.' ''

# Mixed Case for Gender (Female, Uppercase)
test './bn 2010 F' 0 'Sophia' '2010: Sophia ranked 1 out of 19000 female names.' ''

# Empty Input (Name Required)
test './bn 2022 m' 1 '' '' 'bn <year> <assigned gender: f|F|m|M|b|B>'


# return code
exit $fails

