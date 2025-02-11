#!/bin/bash

echo -e "Start processing...\n"

output_file="lab1.log"
> "$output_file"

if [[ ! -f "/etc/passwd" ]]; then
	echo -e "File /etc/passwd not found!\n"
	exit 1
fi

echo -e "Processing /etc/passwd file...\n"

while IFS= read -r line; do
	user_name=$(echo "$line" | cut -d':' -f1)
	user_id=$(echo "$line" | cut -d':' -f3)

	s="user $user_name has id $user_id"
	echo "$s" >> "$output_file"
done < "/etc/passwd"

echo -e "Getting last password change date for root...\n"

last_password_change=$(chage -l root | awk -F':' 'NR==1 {print $2}')
echo "Last password change date for root: $last_password_change" >> "$output_file"

if [[ ! -f "/etc/group" ]]; then
	echo -e "File /etc/group not found!\n"
	exit 1
fi

echo -e "Processing /etc/group file...\n"

awk -F':' '{print $1}' "/etc/group" | paste -sd ',' - >> "$output_file"

echo -e "Setting warning skeleton for new users...\n"

echo "Be careful!" > "/etc/skel/warning.txt"

echo -e "Creating u1 and g1...\n"

sudo groupadd "g1"
sudo useradd -m -s /bin/bash "u1"
echo "u1:12345678" | sudo chpasswd
sudo usermod -a -G "g1" "u1"

echo -e "Getting info about user u1...\n"

echo "Name: u1" >> "$output_file"
id=$(id -u "u1")
groups=$(id -Gn "u1")
groupIds=$(id -G "u1")
echo "Id: $id" >> "$output_file"
echo "Groups: $groups" >> "$output_file"
echo "GroupIds: $groupIds" >> "$output_file"

echo -e "Creating user and adding user to g1...\n"

sudo useradd -m -s /bin/bash "user"
echo "user:12345678" | sudo chpasswd
sudo usermod -a -G "g1" "user"
groupUsers=$(awk -F':' -v group="g1" '$1 == group {print $4}' /etc/group)
echo "Group users: $groupUsers" >> "$output_file"

echo -e "Changing u1 shell to mc...\n"

sudo usermod -s /usr/bin/mc "u1"
