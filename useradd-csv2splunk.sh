#!/bin/bash
export LANG=”C”
export SPLUNK_HOME=/opt/splunk

#note: You must set the admin password from the splunk databag

while IFS=, read email firstname lastname role
do
  echo "processing ${email}..."
        username=$( echo $email | cut -d\@ -f1)
        password=`</dev/urandom tr -dc A-Za-z0-9 | head -c20`
        roleStr="${role%\\n}"
  fullname="$firstname $lastname"
        $SPLUNK_HOME/bin/splunk add user $username -password $password -role $roleStr -email $email -realname "$fullname" -auth admin:CHANGEME
  echo "...successfully added $username"
done < $1

