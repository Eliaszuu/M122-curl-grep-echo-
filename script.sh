#!/bin/bash
set -eu

OUTPUT_FORMAT="${1:-human-readable}"

URL="https://www.srf.ch/meteo"

extract_data() {
    curl -s "$URL" | pup 'div.weather-data' text{}
}

human_readable() {
    local temperature="$1"
    local forecast="$2"

    echo -e "\033[1;32mTemperatur:\033[0m $temperature"
    echo -e "\033[1;34mVorhersage:\033[0m $forecast"
}

structured_json() {
    local temperature="$1"
    local forecast="$2"

    echo -e "{\"temperature\": \"$temperature\", \"forecast\": \"$forecast\"}"
}

raw_data=$(extract_data)

temperature=$(echo "$raw_data" | grep -oP '(?<=Temperature:)[^<]+')
forecast=$(echo "$raw_data" | grep -oP '(?<=Forecast:)[^<]+')

if [ -z "$temperature" ] || [ -z "$forecast" ]; then
    echo "Fehler: Keine Wetterdaten gefunden!"
    exit 1
fi

if [ "$OUTPUT_FORMAT" == "human-readable" ]; then
    human_readable "$temperature" "$forecast"
else
    structured_json "$temperature" "$forecast"
fi
