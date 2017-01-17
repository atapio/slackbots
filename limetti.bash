#!/bin/bash
set -e

MENU_URL="http://limettiravintola.fi/1452-2/"
CHANNEL=${CHANNEL:-lounas}
BOT_USERNAME=${BOT_USERNAME:-limetti}
BOT_EMOJI=${BOT_EMOJI:-stew}

PUP=${PUP:-pup}
JQ=${JQ:-jq}

echoerr() { echo "$@" 1>&2; }

# Make sure WEBHOOK_URL is defined
if [ "x$WEBHOOK_URL" = "x" ];
then
  echoerr "WEBHOOK_URL is not defined"
  exit 1
fi

# Confirm that tools exist
command -v "$PUP" >/dev/null 2>&1 || (echoerr "pup not found"; exit 2)
command -v "$JQ" >/dev/null 2>&1 || (echoerr "jq not found"; exit 3)

SLACK_JSON="{ text: ., channel: \"#$CHANNEL\", \"username\": \"$BOT_USERNAME\", \"icon_emoji\": \":$BOT_EMOJI:\"}"

day_of_week=$(date +%A)

case $day_of_week in
Monday)
    div_id=tab-maanantai
    ;;
Tuesday)
    div_id=tab-tiistai
    ;;
Wednesday)
    div_id=tab-keskiviikko
    ;;
Thursday)
    div_id=tab-torstai
    ;;
Friday)
    div_id=tab-perjantai
    ;;
*)
    ;;
esac

if [ "x$div_id" != "x" ]
then
    todays_menu=$(curl -s "$MENU_URL" | $PUP "div#$div_id div.data h4 text{}")
    #echo "$todays_menu"
    echo "$todays_menu" | $JQ -R . | jq -s "join(\"\n\") | $SLACK_JSON" | curl -s -X POST --data-urlencode "payload@-" "$WEBHOOK_URL"
fi
