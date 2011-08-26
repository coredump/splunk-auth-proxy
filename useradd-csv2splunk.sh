#!/bin/bash
export LANG=”C”
SPLUNKHOME=/opt/splunk/bin/


	while IFS=, read email firstname lastname role
	do
		echo "processing ${email}..."
                username=$( echo $email | cut -d\@ -f1)
                password=`</dev/urandom tr -dc A-Za-z0-9 | head -c20`
                roleStr="${role%\\n}"
                $SPLUNKHOME/splunk add user $username -password $password -role $roleStr -auth admin:changeme 
		echo "...successfully added $username"
	done < $1

