#!/bin/bash
set -e

MENU_URL="http://www.mau-kas.fi/ravintola.html?listtype=lunch&ci=0"
CHANNEL=${CHANNEL:-lounas}
BOT_USERNAME=${BOT_USERNAME:-MAU-KAS}
BOT_EMOJI=${BOT_EMOJI:-stew}

PUP_EXECUTABLE=pup
JQ_EXECUTABLE=jq

echoerr() { echo "$@" 1>&2; }

# Make sure WEBHOOK_URL is defined
if [ "x$WEBHOOK_URL" = "x" ];
then
  echoerr "WEBHOOK_URL is not defined"
  exit 1
fi

# Confirm that tools exist
command -v "$PUP_EXECUTABLE" >/dev/null 2>&1 || (echoerr "pup not found"; exit 2)
command -v "$JQ_EXECUTABLE" >/dev/null 2>&1 || (echoerr "jq not found"; exit 3)

SLACK_JSON="{ text: ., channel: \"#$CHANNEL\", \"username\": \"$BOT_USERNAME\", \"icon_emoji\": \":$BOT_EMOJI:\"}"

todays_menu=$(curl -s "$MENU_URL" | $PUP_EXECUTABLE -l 1 'div.restaurant_menu div.restaurant_menuitemname text{}'|grep -v "^$")
echo "$todays_menu" | $JQ_EXECUTABLE -R . | jq -s "join(\"\n\") | $SLACK_JSON" | curl -s -X POST --data-urlencode "payload@-" "$WEBHOOK_URL"
