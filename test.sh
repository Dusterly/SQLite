#!/bin/bash
function echo_colored {
	local color=$1
	local text=$2
	echo "\033[${color}m" #]
	echo "$text"
	echo "\033[0m" #]
}

function display_result {
	local red=31
	local green=32
	if [[ $1 = 0 ]]; then
		echo_colored $green "😍  SUCCESS 😍"
	else
		echo_colored $red "🤕  FAILURE 🤕"
	fi
}

docker build -f test.dockerfile -t test_run .

result=$?
display_result $result

if [[ $result = 0 ]]; then
    echo "clean-up after test" &&
    docker image rm test_run
fi
