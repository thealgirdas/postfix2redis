#!/bin/bash
# A very simple and hopefully not overengineered email content to redis adapter.
# Expects input as an email source content. Extracts recipients address. Inserts into Redis storage
#
# Test it out with: mail -s "Hello" root@localhost < /etc/passwd
# All items belonging to recipient: redis-cli HGETALL "email:root@localhost.localdomain"
# Specific item: redis-cli HGET "email:root@localhost.localdomain" id-1415835220
#
# Potential issues and improvements:
# * [FIXED] A race condition based on timestamp, as it only deals in seconds. A newer 
#   email arrival (in a subsecond) could overwrite the older one.
# * After playing and understanding Redis more, fetching all email items with 
#   content seems ineficient for production. So a different storage schema might 
#   be more practical. E.g. using additional list (perhaps "id-lookup:<address>") 
#   to populate only with keys (id-<nnnnnn>) from "email:<address>" hashes.

REDIS_CLI="/usr/bin/redis-cli"
#REDIS_CLI="/usr/local/bin/redis-cli"

CONTENT=""
while read -r line
do
	CONTENT+="$line"$'\n'
done

# stop reading after first match! And get the email address.
RCPT_TO=`echo "$CONTENT" grep -m 1 "^To: " | awk -F:\  '/^To: / { print $2 }'`
#DATE=`echo "$CONTENT" grep -m 1 "^Date: " | awk -F:\  '/^Date: / { print $2 }'`
#TIMESTAMP=`echo "$DATE" | date +%s -f -`
TIMESTAMP=`date +%s%N`


# check if email is found else return an error.
if [ ! -n "$RCPT_TO" ]
then
    echo "Error: Email address seems to be empty."
    exit 1
fi

#echo "$DATE"
#echo "$TIMESTAMP"
#echo "$RCPT_TO"
#echo "Inserting $RCPT_TO into Redis"
#echo "$CONTENT" | $REDIS_CLI -x SADD "email:$RCPT_TO" 
echo "$CONTENT" | $REDIS_CLI -x HMSET "email:$RCPT_TO" "id-$TIMESTAMP"

exit 0
