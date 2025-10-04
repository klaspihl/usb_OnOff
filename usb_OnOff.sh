#!/bin/bash

TEMP_THRESHOLD_HIGH="${TEMP_THRESHOLD_HIGH:-65}"
TEMP_THRESHOLD_LOW="${TEMP_THRESHOLD_LOW:-45}"
UHUBCTL_LOCATION="${UHUBCTL_LOCATION:-7-1}"
UHUBCTL_PORT="${UHUBCTL_PORT:-2}"
POWER_STATUS=undefined
FREQ="${FREQ:-30}"

stop_now=false
trap "stop_now=true" SIGTERM SIGINT
echo "$(date '+%Y-%m-%d %H:%M:%S') initiate with high/low threshould at: $TEMP_THRESHOLD_HIGH/$TEMP_THRESHOLD_LOW)"
while true; do
    # Get CPU temperature in Celsius (using k10temp for AMD CPUs)
    TEMP=$(sensors | awk '/Tctl:/ {print int($2)}' | head -n1)

    if [ -z "$TEMP" ]; then
        echo "Could not read CPU temperature."
        for ((i=0; i<$FREQ; i++)); do
            if $stop_now; then
                exit 0
            fi
            sleep 1
        done
        continue
    fi

    #echo "Current CPU temperature: $TEMP°C"

    if [ "$TEMP" -ge "$TEMP_THRESHOLD_HIGH" ] && [ "$POWER_STATUS" != "on" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - USB POWER ON (TEMP: $TEMP°C)"
        uhubctl -l "$UHUBCTL_LOCATION" -p "$UHUBCTL_PORT" -a on >/dev/null 2>&1
        POWER_STATUS=on
    elif [ "$TEMP" -le "$TEMP_THRESHOLD_LOW" ] && [ "$POWER_STATUS" != "off" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - USB POWER OFF (TEMP: $TEMP°C)"
        uhubctl -l "$UHUBCTL_LOCATION" -p "$UHUBCTL_PORT" -a off >/dev/null 2>&1
        POWER_STATUS=off
    fi
    for ((i=0; i<$FREQ; i++)); do
        if $stop_now; then
            exit 0
        fi
        sleep 1
    done
done