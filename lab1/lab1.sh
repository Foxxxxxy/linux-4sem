#!/bin/bash

echo -e "Start processing...\n"

input_file="/etc/passwd"
output_file="lab1.log"

if [[ ! -f "$input_file" ]]; then
	echo -e "File $input_file not found!\n"
	exit 1
fi

> "$output_file"

echo -e "Processing /etc/passwd file...\n"

while IFS= read -r line; do
	user_name=$(echo "$line" | cut -d':' -f1)
	user_id=$(echo "$line" | cut -d':' -f3)

	s="user $user_name has id $user_id"
	echo "$s" >> "$output_file"
done < "$input_file"

echo -e "Getting last password change date for root...\n"

last_password_change=$(passwd root -S | cut -d' ' -f3)
echo "Last password change date for root: $last_password_change" >> "$output_file" 
