#!/bin/bash

echo -e "Start processing...\n"

output_file="/home/lab1.log"
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

groupadd "g1"
useradd -m -s /bin/bash "u1"
echo "u1:12345678" | chpasswd
usermod -a -G "g1" "u1"

echo -e "Getting info about user u1...\n"

echo "Name: u1" >> "$output_file"
id=$(id -u "u1")
groups=$(id -Gn "u1")
groupIds=$(id -G "u1")
echo "Id: $id" >> "$output_file"
echo "Groups: $groups" >> "$output_file"
echo "GroupIds: $groupIds" >> "$output_file"

echo -e "Adding user to g1...\n"

usermod -a -G "g1" "user"
groupUsers=$(awk -F':' -v group="g1" '$1 == group {print $4}' /etc/group)
echo "Group users: $groupUsers" >> "$output_file"

echo -e "Changing u1 shell to mc...\n"

usermod -s /usr/bin/mc "u1"

echo -e "Creating u2...\n"

useradd -m "u2"
echo "u2:87654321" | chpasswd

echo -e "Creating test13...\n"

mkdir /home/test13
cp "$output_file" /home/test13/lab1-1.log
cp "$output_file" /home/test13/lab1-2.log

echo -e "Granting permissions for test13...\n"

usermod -a -G "g1" "u2"
chown u1:g1 -R /home/test13
chmod 750 /home/test13
chmod 640 /home/test13/*

echo -e "Creating test14 and granting permissions to it...\n"

mkdir /home/test14
chmod 1777 /home/test14
chown u1 /home/test14

echo -e "Copying nano and granting permissions to modify test13 files...\n"

cp /usr/bin/nano /home/test14
chmod u+s /home/test14/nano

echo -e "Creating secret file and removing read access...\n"

mkdir /home/test15
touch /home/test15/secret_file
echo "secret" >> /home/test15/secret_file
chmod a-r /home/test15

echo -e "Granting permissions to sudo for u1...\n"

rule="u1 ALL = /usr/bin/passwd [A-Za-z]*, !/usr/bin/passwd *root*"
echo "$rule" >> /etc/sudoers
