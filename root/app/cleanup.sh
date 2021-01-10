#!/usr/bin/with-contenv bash

. /config/.env

# define array for input values
declare -A DISKOVER_ARRAY
DISKOVER_ARRAY[REDIS_HOST]=${REDIS_HOST:-redis}
DISKOVER_ARRAY[REDIS_PORT]=${REDIS_PORT:-6379}

DISKOVER_ARRAY[DISKOVER_OPTS]="${DISKOVER_ARRAY[DISKOVER_OPTS]} -i ${DISKOVER_ARRAY[INDEX_NAME]}"

# killing existing workers before starting new ones
echo "killing existing workers..."
if [ -f "/tmp/diskover_bot_pids" ]; then
    /bin/bash /app/diskover/diskover-bot-launcher.sh -k > /dev/null 2>&1
    sleep 3
fi

# empty existing redis queue
echo "emptying current redis queues..."
rq empty -u redis://"${DISKOVER_ARRAY[REDIS_HOST]}":"${DISKOVER_ARRAY[REDIS_PORT]}" diskover_crawl diskover diskover_calcdir failed
sleep 3

echo "killing dangling workers..."
/bin/bash /app/diskover/diskover-bot-launcher.sh -k > /dev/null 2>&1
sleep 3