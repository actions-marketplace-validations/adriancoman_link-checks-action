#!/bin/bash

# Change this value to match the name of your Kotlin file
FILE="PagoConfig/Configs/RO/LegalRO.swift,PagoConfig/Configs/EN/LegalEN.swift"

# Split the file names into an array
IFS=',' read -ra FILE_ARRAY <<< "$FILE"

# Use grep to find all the URLs in each file
URLS=""
for filename in "${FILE_ARRAY[@]}"
do
    urls=$(grep -o 'https\?://[a-zA-Z0-9./?=_&-]\+' $filename)
    URLS="$URLS $urls"
done

# Check the status code of each URL with curl
i=0
failed_urls=()
for url in $URLS
do
    status_code=$(curl --silent --head --output /dev/null --write-out '%{http_code}' $url)
    if [ $status_code -ne 200 ]; then
      echo "$i: $url - Failed (HTTP $status_code)"
      failed_urls+=("$url")
    fi
    ((i++))
done


# If there were failed URLs, exit with an error
if [ ${#failed_urls[@]} -gt 0 ]; then
    echo "The following URLs failed:"
    printf '%s\n' "${failed_urls[@]}"
    exit 1
fi