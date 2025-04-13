#!/bin/bash
set -eu
URL="https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population"
OUTPUT_FORMAT=$1

# HTML-Inhalt holen und relevante Tabellenzeilen extrahieren (ohne Kopfzeile)
rows=$(curl -s "$URL" | pup 'table.wikitable tbody tr json{}' | jq -c '.[]' | tail -n +2 | head -n 20)

declare -a countries populations percentages

while read -r row; do
    # Land: entweder in .children[0].children oder direkt als Text
    country=$(echo "$row" | jq -r '
        .children[0].children[]?.text // empty
    ' | paste -sd " " - | sed 's/\[[^]]*\]//g' | xargs)

    [ -z "$country" ] && country=$(echo "$row" | jq -r '.children[0].text // empty' | sed 's/\[[^]]*\]//g' | xargs)

    # Bevölkerung & Anteil
    population=$(echo "$row" | jq -r '.children[1].text // empty' | xargs)
    percentage=$(echo "$row" | jq -r '.children[2].text // empty' | xargs)

    [ "$country" == "World" ] && [ -z "$percentage" ] && percentage="100%"

    countries+=("$country")
    populations+=("$population")
    percentages+=("$percentage")
done <<< "$rows"

if [ "$OUTPUT_FORMAT" == "pretty" ]; then
    echo -e "\n\033[1;34mTop 20 Länder nach Bevölkerung:\033[0m
\033[1;32m-------------------------------------------------------------\033[0m
\033[1;33mLand                          Bevölkerung         Anteil\033[0m
\033[1;32m-------------------------------------------------------------\033[0m"

    for i in "${!countries[@]}"; do
        printf "\033[1;33m%-30s\033[0m \033[1;36m%-20s\033[0m \033[1;31m%s\033[0m\n" \
            "${countries[$i]}" "${populations[$i]}" "${percentages[$i]}"
    done
elif [ "$OUTPUT_FORMAT" == "Json" ]; then
    echo "["
    for i in "${!countries[@]}"; do
        echo "  { \"country\": \"${countries[$i]}\", \"population\": \"${populations[$i]}\", \"percentage\": \"${percentages[$i]}\" }$( [[ $i -lt $((${#countries[@]}-1)) ]] && echo "," )"
    done
    echo "]"
else
    echo "❌ Ungültiges Format. Bitte wähle 'pretty' oder 'json'."
    exit 1
fi
